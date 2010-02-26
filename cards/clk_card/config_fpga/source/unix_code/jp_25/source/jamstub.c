/****************************************************************************/
/*																			*/
/*	Module:			jamstub.c												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997-2000				*/
/*																			*/
/*	Description:	Main source file for stand-alone JAM test utility.		*/
/*																			*/
/*					Supports Altera ByteBlaster hardware download cable		*/
/*					on Windows 95 and Windows NT operating systems.			*/
/*					(A device driver is required for Windows NT.)			*/
/*																			*/
/*					Also supports BitBlaster hardware download cable on		*/
/*					Windows 95, Windows NT, and UNIX platforms.				*/
/*																			*/
/*	Revisions:		1.1	added dynamic memory allocation						*/
/*					1.11 added multi-page memory allocation for file_buffer */
/*                    to permit DOS version to read files larger than 64K   */
/*					1.2 fixed control port initialization for ByteBlaster	*/
/*					2.2 updated usage message, added support for alternate	*/
/*					  cable types, moved porting macros in jamport.h,		*/
/*					  fixed bug in delay calibration code for 16-bit port	*/
/*					2.3 added support for static memory						*/
/*						fixed /W4 warnings									*/
/*																			*/
/****************************************************************************/

//--------------------------------------------------------
// For commands via the MCE to the JTAG chain
//--------------------------------------------------------
//#define MCE_CMD 1
//#ifdef MCE_CMD

// These are the MCE include files
#include <mce_library.h>

// Default device, config files
#define CMD_DEVICE "/dev/mce_cmd0"
#define CONFIG_FILE "/etc/mce/mce.cfg"

#define SIZE 256

void print_u32(u32 *data, int count)
{
	int i;
	for (i=0; i<count; i++) {
		printf("%u ", data[i]);
	}
	printf("\n");
}

int mce_error = 0;
int mce_num_param = 0;
u32 mce_data[SIZE];
u32 mce_more_data[SIZE];
mce_context_t *mce;

mce_param_t cc_fw_rev;
mce_param_t cc_jtag0;
mce_param_t cc_jtag1;
mce_param_t cc_jtag2;

//#endif

#define PORT_MCE 0x100
#define PORT0 0
#define PORT1 1
#define PORT2 2
//--------------------------------------------------------

#ifndef NO_ALTERA_STDIO
#define NO_ALTERA_STDIO
#endif

#if ( _MSC_VER >= 800 )
#pragma warning(disable:4115)
#pragma warning(disable:4201)
#pragma warning(disable:4214)
#pragma warning(disable:4514)
#endif

#include "jamport.h"

#if PORT == WINDOWS
#include <windows.h>
#else
typedef int BOOL;
typedef unsigned char BYTE;
typedef unsigned short WORD;
typedef unsigned long DWORD;
#define TRUE 1
#define FALSE 0
#endif

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <io.h>
#include <fcntl.h>
#include <process.h>
#if defined(USE_STATIC_MEMORY)
	#define N_STATIC_MEMORY_KBYTES ((unsigned int) USE_STATIC_MEMORY)
	#define N_STATIC_MEMORY_BYTES (N_STATIC_MEMORY_KBYTES * 1024)
	#define POINTER_ALIGNMENT sizeof(DWORD)
#else /* USE_STATIC_MEMORY */
	#include <malloc.h>
	#define POINTER_ALIGNMENT sizeof(BYTE)
#endif /* USE_STATIC_MEMORY */
#include <time.h>
//#include <conio.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>

#if PORT == DOS
#include <bios.h>
#endif

#include "jamexprt.h"

#if PORT == WINDOWS
#define PGDC_IOCTL_GET_DEVICE_INFO_PP 0x00166A00L
#define PGDC_IOCTL_READ_PORT_PP       0x00166A04L
#define PGDC_IOCTL_WRITE_PORT_PP      0x0016AA08L
#define PGDC_IOCTL_PROCESS_LIST_PP    0x0016AA1CL
#define PGDC_READ_INFO                0x0a80
#define PGDC_READ_PORT                0x0a81
#define PGDC_WRITE_PORT               0x0a82
#define PGDC_PROCESS_LIST             0x0a87
#define PGDC_HDLC_NTDRIVER_VERSION    2
#define PORT_IO_BUFFER_SIZE           256
#endif

#if PORT == WINDOWS
#ifdef __BORLANDC__
/* create dummy inp() and outp() functions for Borland 32-bit compile */
WORD inp(WORD address) { address = address; return(0); }
void outp(WORD address, WORD data) { address = address; data = data; }
#else
#pragma intrinsic (inp, outp)
#endif
#endif

/*
*	For Borland C compiler (16-bit), set the stack size
*/
#if PORT == DOS
#ifdef __BORLANDC__
extern unsigned int _stklen = 50000;
#endif
#endif

/************************************************************************
*
*	Global variables
*/

/* file buffer for JAM input file */
#if PORT == DOS
char **file_buffer = NULL;
#else
char *file_buffer = NULL;
#endif
long file_pointer = 0L;
long file_length = 0L;

/* delay count for one millisecond delay */
long one_ms_delay = 0L;

/* delay count to reduce the maximum TCK frequency */
int tck_delay = 0;

/* serial port interface available on all platforms */
BOOL jtag_hardware_initialized = FALSE;
char *serial_port_name = NULL;
BOOL specified_com_port = FALSE;
int com_port = -1;
void initialize_jtag_hardware(void);
void close_jtag_hardware(void);

#if defined(USE_STATIC_MEMORY)
	unsigned char static_memory_heap[N_STATIC_MEMORY_BYTES] = { 0 };
#endif /* USE_STATIC_MEMORY */

#if defined(USE_STATIC_MEMORY) || defined(MEM_TRACKER)
	unsigned int n_bytes_allocated = 0;
#endif /* USE_STATIC_MEMORY || MEM_TRACKER */

#if defined(MEM_TRACKER)
	unsigned int peak_memory_usage = 0;
	unsigned int peak_allocations = 0;
	unsigned int n_allocations = 0;
#if defined(USE_STATIC_MEMORY)
	unsigned int n_bytes_not_recovered = 0;
#endif /* USE_STATIC_MEMORY */
	const DWORD BEGIN_GUARD = 0x01234567;
	const DWORD END_GUARD = 0x76543210;
#endif /* MEM_TRACKER */

#if PORT == WINDOWS || PORT == DOS || PORT == UNIX
#include <sys/io.h>
#define OPEN 1
#define CLOSED 0
//#include <sys/ioctl.h>
//#define outp outb
//#define inp inb
long tck_freq = 10000000;

/* parallel port interface available on PC only */
BOOL specified_lpt_port = FALSE;
BOOL specified_lpt_addr = FALSE;
int lpt_port = 1;
int initial_lpt_ctrl = 0;
WORD lpt_addr = 0x378;
WORD lpt_addr_table[3] = { 0x3bc, 0x378, 0x278 };
BOOL alternative_cable_l = FALSE;
BOOL alternative_cable_x = FALSE;
void write_byteblaster(int port, int data);
int read_byteblaster(int port);
#endif

#if PORT==WINDOWS
#ifndef __BORLANDC__
WORD lpt_addresses_from_registry[4] = { 0 };
#endif
#endif

#if PORT == WINDOWS
/* variables to manage cached I/O under Windows NT */
BOOL windows_nt = FALSE;
int port_io_count = 0;
HANDLE nt_device_handle = INVALID_HANDLE_VALUE;
struct PORT_IO_LIST_STRUCT
{
	USHORT command;
	USHORT data;
} port_io_buffer[PORT_IO_BUFFER_SIZE];
extern void flush_ports(void);
BOOL initialize_nt_driver(void);
#endif

/* function prototypes to allow forward reference */
extern void delay_loop(long count);

/*
*	This structure stores information about each available vector signal
*/
struct VECTOR_LIST_STRUCT
{
	char *signal_name;
	int  hardware_bit;
	int  vector_index;
};

/*
*	Vector signals for ByteBlaster:
*
*	tck (dclk)    = register 0, bit 0
*	tms (nconfig) = register 0, bit 1
*	tdi (data)    = register 0, bit 6
*	tdo (condone) = register 1, bit 7 (inverted!)
*	nstatus       = register 1, bit 4 (not inverted)
*/
struct VECTOR_LIST_STRUCT vector_list[] =
{
	/* add a record here for each vector signal */
	{ "**TCK**",   0, -1 },
	{ "**TMS**",   1, -1 },
	{ "**TDI**",   6, -1 },
	{ "**TDO**",   7, -1 },
	{ "TCK",       0, -1 },
	{ "TMS",       1, -1 },
	{ "TDI",       6, -1 },
	{ "TDO",       7, -1 },
	{ "DCLK",      0, -1 },
	{ "NCONFIG",   1, -1 },
	{ "DATA",      6, -1 },
	{ "CONF_DONE", 7, -1 },
	{ "NSTATUS",   4, -1 }
};

#define VECTOR_SIGNAL_COUNT ((int)(sizeof(vector_list)/sizeof(vector_list[0])))

BOOL verbose = FALSE;

//--------------------------------------------------------
// JAM Player functions
//--------------------------------------------------------
/************************************************************************
*
*	Customized interface functions for JAM interpreter I/O:
*
*	jam_getc()
*	jam_seek()
*	jam_jtag_io()
*	jam_message()
*	jam_delay()
*/

int jam_getc(void)
{
	int ch = EOF;

	if (file_pointer < file_length)
	{
#if PORT == DOS
		ch = (int) file_buffer[file_pointer >> 14L][file_pointer & 0x3fffL];
		++file_pointer;
#else
		ch = (int) file_buffer[file_pointer++];
#endif
	}

	return (ch);
}

int jam_seek(long offset)
{
	int return_code = EOF;

	if ((offset >= 0L) && (offset < file_length))
	{
		file_pointer = offset;
		return_code = 0;
	}

	return (return_code);
}

int jam_jtag_io(int tms, int tdi, int read_tdo)
{
	int data = 0;
	int tdo = 0;
	int i = 0;
	int result = 0;
	char ch_data = 0;

	if (!jtag_hardware_initialized)
	{
		initialize_jtag_hardware();
		jtag_hardware_initialized = TRUE;
	}

	if (specified_com_port)
	{
		ch_data = (char)
			((tdi ? 0x01 : 0) | (tms ? 0x02 : 0) | 0x60);

		write(com_port, &ch_data, 1);

		if (read_tdo)
		{
			ch_data = 0x7e;
			write(com_port, &ch_data, 1);
			for (i = 0; (i < 100) && (result != 1); ++i)
			{
				result = read(com_port, &ch_data, 1);
			}
			if (result == 1)
			{
				tdo = ch_data & 0x01;
			}
			else
			{
				fprintf(stderr, "Error:  BitBlaster not responding\n");
			}
		}

		ch_data = (char)
			((tdi ? 0x01 : 0) | (tms ? 0x02 : 0) | 0x64);

		write(com_port, &ch_data, 1);
	}
	else
	{
#if PORT == WINDOWS || PORT == DOS || PORT == UNIX
		// This is where the conversion for TMS and TDI takes place
		// Without the -c option (always), ignore the first two lines of this assignment.
		// Data is an integer
		data = (alternative_cable_l ? ((tdi ? 0x01 : 0) | (tms ? 0x04 : 0)) :
		       (alternative_cable_x ? ((tdi ? 0x01 : 0) | (tms ? 0x04 : 0) | 0x10) :
		       // if tdi is TDI_HIGH=1, then OR in "00000100" with data.  TDI is bit 2 of data.
		       // if tms is TMS_HIGH=1, then OR in "00000010" with data.  TMS is bit 1 of data.
		       ((tdi ? 0x40 : 0) | (tms ? 0x02 : 0))));

		// Here are the triads of writes to the Byte Blaster.
		// Write #1
		write_byteblaster(PORT0, data);

		// The read, if necessary, always occurs after the first of the writes in a triad.
		// Note that we write to port 0, and read from port 1.
		if (read_tdo)
		{
			//printf("cable1 = %s; cablex = %s", alternative_cable_l ? "true" : "false", alternative_cable_x ? "true" : "false");
			tdo = read_byteblaster(PORT1);
			tdo = (alternative_cable_l ? ((tdo & 0x40) ? 1 : 0) :
			      (alternative_cable_x ? ((tdo & 0x10) ? 1 : 0) :
			      // This is the statement executed
			      // The TDO bit is the MSB.  This un-inverts the bit..  See p.13 of AN122.
			      ((tdo & 0x80) ? 0 : 1)));
//			      ((tdo & 0x80) ? 1 : 0)));
		}

//		if (verbose)
//		{
//			// Bryce
//			printf("tdo: %#x\n", tdo);
//		    fflush(stdout);
//		}

		// Write #2
		// OR in "00000001" with data.  TCK is bit 0 of data.  TCK is always asserted on the second write of a triad.
		write_byteblaster(PORT0, data | (alternative_cable_l ? 0x02 : (alternative_cable_x ? 0x02: 0x01)));

		// Write #3
		// Back to the data from Write #1.  Identical.
		write_byteblaster(PORT0, data);
#else
		/* parallel port interface not available */
		tdo = 0;
#endif
	}

	if (tck_delay != 0) delay_loop(tck_delay);

	return (tdo);
}

void jam_message(char *message_text)
{
	puts(message_text);
	fflush(stdout);
}

void jam_export_integer(char *key, long value)
{
	if (verbose)
	{
		printf("Export: key = \"%s\", value = %ld\n", key, value);
		fflush(stdout);
	}
}

#define HEX_LINE_CHARS 72
#define HEX_LINE_BITS (HEX_LINE_CHARS * 4)

char conv_to_hex(unsigned long value)
{
	char c;

	if (value > 9)
	{
		c = (char) (value + ('A' - 10));
	}
	else
	{
		c = (char) (value + '0');
	}

	return (c);
}

void jam_export_boolean_array(char *key, unsigned char *data, long count)
{
	unsigned long size, line, lines, linebits, value, j, k;
	char string[HEX_LINE_CHARS + 1];
	long i, offset;

	if (verbose)
	{
		if (count > HEX_LINE_BITS)
		{
			printf("Export: key = \"%s\", %ld bits, value = HEX\n", key, count);
			lines = (count + (HEX_LINE_BITS - 1)) / HEX_LINE_BITS;

			for (line = 0; line < lines; ++line)
			{
				if (line < (lines - 1))
				{
					linebits = HEX_LINE_BITS;
					size = HEX_LINE_CHARS;
					offset = count - ((line + 1) * HEX_LINE_BITS);
				}
				else
				{
					linebits = count - ((lines - 1) * HEX_LINE_BITS);
					size = (linebits + 3) / 4;
					offset = 0L;
				}

				string[size] = '\0';
				j = size - 1;
				value = 0;

				for (k = 0; k < linebits; ++k)
				{
					i = k + offset;
					if (data[i >> 3] & (1 << (i & 7))) value |= (1 << (i & 3));
					if ((i & 3) == 3)
					{
						string[j] = conv_to_hex(value);
						value = 0;
						--j;
					}
				}
				if ((k & 3) > 0) string[j] = conv_to_hex(value);

				printf("%s\n", string);
			}

			fflush(stdout);
		}
		else
		{
			size = (count + 3) / 4;
			string[size] = '\0';
			j = size - 1;
			value = 0;

			for (i = 0; i < count; ++i)
			{
				if (data[i >> 3] & (1 << (i & 7))) value |= (1 << (i & 3));
				if ((i & 3) == 3)
				{
					string[j] = conv_to_hex(value);
					value = 0;
					--j;
				}
			}
			if ((i & 3) > 0) string[j] = conv_to_hex(value);

			printf("Export: key = \"%s\", %ld bits, value = HEX %s\n",
				key, count, string);
			fflush(stdout);
		}
	}
}

void jam_delay(long microseconds)
// This delays JAM execution for a period = 'microseconds'
{
#if PORT == WINDOWS
	/* if Windows NT, flush I/O cache buffer before delay loop */
	if (windows_nt && (port_io_count > 0)) flush_ports();
#endif

	delay_loop(microseconds *
		((one_ms_delay / 1000L) + ((one_ms_delay % 1000L) ? 1 : 0)));

	if (verbose)
	{
		// Bryce
		//printf(">> jam_delay: microseconds = %ld\n", microseconds);
	    //fflush(stdout);
	}
}

int jam_vector_map
(
	int signal_count,
	char **signals
)
{
	int signal, vector, ch_index, diff;
	int matched_count = 0;
	char l, r;

	for (vector = 0; (vector < VECTOR_SIGNAL_COUNT); ++vector)
	{
		vector_list[vector].vector_index = -1;
	}

	for (signal = 0; signal < signal_count; ++signal)
	{
		diff = 1;
		for (vector = 0; (diff != 0) && (vector < VECTOR_SIGNAL_COUNT);
			++vector)
		{
			if (vector_list[vector].vector_index == -1)
			{
				ch_index = 0;
				do
				{
					l = signals[signal][ch_index];
					r = vector_list[vector].signal_name[ch_index];
					diff = (((l >= 'a') && (l <= 'z')) ? (l - ('a' - 'A')) : l)
						- (((r >= 'a') && (r <= 'z')) ? (r - ('a' - 'A')) : r);
					++ch_index;
				}
				while ((diff == 0) && (l != '\0') && (r != '\0'));

				if (diff == 0)
				{
					vector_list[vector].vector_index = signal;
					++matched_count;
				}
			}
		}
	}

	return (matched_count);
}

int jam_vector_io
(
	int signal_count,
	long *dir_vect,
	long *data_vect,
	long *capture_vect
)
{
	int signal, vector, bit;
	int matched_count = 0;
	int data = 0;
	int mask = 0;
	int dir = 0;
	int i = 0;
	int result = 0;
	char ch_data = 0;

	if (!jtag_hardware_initialized)
	{
		initialize_jtag_hardware();
		jtag_hardware_initialized = TRUE;
	}

	/*
	*	Collect information about output signals
	*/
	for (vector = 0; vector < VECTOR_SIGNAL_COUNT; ++vector)
	{
		signal = vector_list[vector].vector_index;

		if ((signal >= 0) && (signal < signal_count))
		{
			bit = (1 << vector_list[vector].hardware_bit);

			mask |= bit;
			if (data_vect[signal >> 5] & (1L << (signal & 0x1f))) data |= bit;
			if (dir_vect[signal >> 5] & (1L << (signal & 0x1f))) dir |= bit;

			++matched_count;
		}
	}

	/*
	*	Write outputs to hardware interface, if any
	*/
	if (dir != 0)
	{
		if (specified_com_port)
		{
			ch_data = (char) (((data >> 6) & 0x01) | (data & 0x02) |
					  ((data << 2) & 0x04) | ((data << 3) & 0x08) | 0x60);
			write(com_port, &ch_data, 1);
		}
		else
		{
#if PORT == WINDOWS || PORT == DOS || PORT == UNIX

			// *** What is this write for?
			if (verbose)
			{
				// Bryce
				printf(">> jam_vector_io: Mystery JTAG write.\n");
			    fflush(stdout);
			}
			write_byteblaster(PORT0, data);

			// Bryce: put this here so that I would notice if it's executed.
			exit(0);
#endif
		}
	}

	/*
	*	Read the input signals and save information in capture_vect[]
	*/
	if ((dir != mask) && (capture_vect != NULL))
	{
		if (specified_com_port)
		{
			ch_data = 0x7e;
			write(com_port, &ch_data, 1);
			for (i = 0; (i < 100) && (result != 1); ++i)
			{
				result = read(com_port, &ch_data, 1);
			}
			if (result == 1)
			{
				data = ((ch_data << 7) & 0x80) | ((ch_data << 3) & 0x10);
			}
			else
			{
				fprintf(stderr, "Error:  BitBlaster not responding\n");
			}
		}
		else
		{
#if PORT == WINDOWS || PORT == DOS || PORT == UNIX

			data = read_byteblaster(PORT1) ^ 0x80; /* parallel port inverts bit 7 */

#endif
		}

		for (vector = 0; vector < VECTOR_SIGNAL_COUNT; ++vector)
		{
			signal = vector_list[vector].vector_index;

			if ((signal >= 0) && (signal < signal_count))
			{
				bit = (1 << vector_list[vector].hardware_bit);

				if ((dir & bit) == 0)	/* if it is an input signal... */
				{
					if (data & bit)
					{
						capture_vect[signal >> 5] |= (1L << (signal & 0x1f));
					}
					else
					{
						capture_vect[signal >> 5] &= ~(unsigned long)
							(1L << (signal & 0x1f));
					}
				}
			}
		}
	}

	return (matched_count);
}

int jam_set_frequency(long tck_freq)
{
	if (tck_freq == -1)
	{
		/* no frequency limit */
		tck_delay = 0;
	}
	else if (tck_freq == 0)
	{
		/* stop the clock */
		tck_delay = -1;
	}
	else
	{
		/* set the clock delay to the period */
		/* corresponding to the selected frequency */
		tck_delay = (one_ms_delay * 1000) / tck_freq;
	}

	if (verbose)
	{
		// Bryce
		printf(">> jam_set_frequency: TCK frequency = %ld kHz\n", tck_freq);
	    fflush(stdout);
	}

	return (0);
}

void *jam_malloc(unsigned int size)
{	unsigned int n_bytes_to_allocate =
#if defined(USE_STATIC_MEMORY) || defined(MEM_TRACKER)
		sizeof(unsigned int) +
#endif /* USE_STATIC_MEMORY || MEM_TRACKER */
#if defined(MEM_TRACKER)
		(2 * sizeof(DWORD)) +
#endif /* MEM_TRACKER */
		(POINTER_ALIGNMENT * ((size + POINTER_ALIGNMENT - 1) / POINTER_ALIGNMENT));

	unsigned char *ptr = 0;


#if defined(MEM_TRACKER)
	if ((n_bytes_allocated + n_bytes_to_allocate) > peak_memory_usage)
	{
		peak_memory_usage = n_bytes_allocated + n_bytes_to_allocate;
	}
	if ((n_allocations + 1) > peak_allocations)
	{
		peak_allocations = n_allocations + 1;
	}
#endif /* MEM_TRACKER */

#if defined(USE_STATIC_MEMORY)
	if ((n_bytes_allocated + n_bytes_to_allocate) <= N_STATIC_MEMORY_BYTES)
	{
		ptr = (&(static_memory_heap[n_bytes_allocated]));
	}
#else /* USE_STATIC_MEMORY */
	ptr = (unsigned char *) malloc(n_bytes_to_allocate);
#endif /* USE_STATIC_MEMORY */

#if defined(USE_STATIC_MEMORY) || defined(MEM_TRACKER)
	if (ptr != 0)
	{
		unsigned int i = 0;

#if defined(MEM_TRACKER)
		for (i = 0; i < sizeof(DWORD); ++i)
		{
			*ptr = (unsigned char) (BEGIN_GUARD >> (8 * i));
			++ptr;
		}
#endif /* MEM_TRACKER */

		for (i = 0; i < sizeof(unsigned int); ++i)
		{
			*ptr = (unsigned char) (size >> (8 * i));
			++ptr;
		}

#if defined(MEM_TRACKER)
		for (i = 0; i < sizeof(DWORD); ++i)
		{
			*(ptr + size + i) = (unsigned char) (END_GUARD >> (8 * i));
			/* don't increment ptr */
		}

		++n_allocations;
#endif /* MEM_TRACKER */

		n_bytes_allocated += n_bytes_to_allocate;
	}
#endif /* USE_STATIC_MEMORY || MEM_TRACKER */

	return ptr;
}

void jam_free(void *ptr)
{
		if
	(
#if defined(MEM_TRACKER)
		(n_allocations > 0) &&
#endif /* MEM_TRACKER */
		(ptr != 0)
	)
	{
		unsigned char *tmp_ptr = (unsigned char *) ptr;

#if defined(USE_STATIC_MEMORY) || defined(MEM_TRACKER)
		unsigned int n_bytes_to_free = 0;
		unsigned int i = 0;
		unsigned int size = 0;
#endif /* USE_STATIC_MEMORY || MEM_TRACKER */
#if defined(MEM_TRACKER)
		DWORD begin_guard = 0;
		DWORD end_guard = 0;


		tmp_ptr -= sizeof(DWORD);
#endif /* MEM_TRACKER */
#if defined(USE_STATIC_MEMORY) || defined(MEM_TRACKER)
		tmp_ptr -= sizeof(unsigned int);
#endif /* USE_STATIC_MEMORY || MEM_TRACKER */
		ptr = tmp_ptr;

#if defined(MEM_TRACKER)
		for (i = 0; i < sizeof(DWORD); ++i)
		{
			begin_guard |= (((DWORD)(*tmp_ptr)) << (8 * i));
			++tmp_ptr;
		}
#endif /* MEM_TRACKER */

#if defined(USE_STATIC_MEMORY) || defined(MEM_TRACKER)
		for (i = 0; i < sizeof(unsigned int); ++i)
		{
			size |= (((unsigned int)(*tmp_ptr)) << (8 * i));
			++tmp_ptr;
		}
#endif /* USE_STATIC_MEMORY || MEM_TRACKER */

#if defined(MEM_TRACKER)
		tmp_ptr += size;

		for (i = 0; i < sizeof(DWORD); ++i)
		{
			end_guard |= (((DWORD)(*tmp_ptr)) << (8 * i));
			++tmp_ptr;
		}

		if ((begin_guard != BEGIN_GUARD) || (end_guard != END_GUARD))
		{
			fprintf(stderr, "Error: memory corruption detected for allocation #%d... bad %s guard\n",
				n_allocations, (begin_guard != BEGIN_GUARD) ? "begin" : "end");
		}

		--n_allocations;
#endif /* MEM_TRACKER */

#if defined(USE_STATIC_MEMORY) || defined(MEM_TRACKER)
		n_bytes_to_free =
#if defined(MEM_TRACKER)
		(2 * sizeof(DWORD)) +
#endif /* MEM_TRACKER */
		sizeof(unsigned int) +
		(POINTER_ALIGNMENT * ((size + POINTER_ALIGNMENT - 1) / POINTER_ALIGNMENT));
#endif /* USE_STATIC_MEMORY || MEM_TRACKER */

#if defined(USE_STATIC_MEMORY)
		if ((((unsigned long) ptr - (unsigned long) static_memory_heap) + n_bytes_to_free) == (unsigned long) n_bytes_allocated)
		{
			n_bytes_allocated -= n_bytes_to_free;
		}
#if defined(MEM_TRACKER)
		else
		{
			n_bytes_not_recovered += n_bytes_to_free;
		}
#endif /* MEM_TRACKER */
#else /* USE_STATIC_MEMORY */
#if defined(MEM_TRACKER)
		n_bytes_allocated -= n_bytes_to_free;
#endif /* MEM_TRACKER */
		free(ptr);
#endif /* USE_STATIC_MEMORY */
	}
#if defined(MEM_TRACKER)
	else
	{
		if (ptr != 0)
		{
			fprintf(stderr, "Error: attempt to free unallocated memory\n");
		}
	}
#endif /* MEM_TRACKER */
}


/************************************************************************
*
*	get_tick_count() -- Get system tick count in milliseconds
*
*	for DOS, use BIOS function _bios_timeofday()
*	for WINDOWS use GetTickCount() function
*	for UNIX use clock() system function
*/
DWORD get_tick_count(void)
{
	DWORD tick_count = 0L;

#if PORT == WINDOWS
	tick_count = GetTickCount();
#elif PORT == DOS
	_bios_timeofday(_TIME_GETCLOCK, (long *)&tick_count);
	tick_count *= 55L;	/* convert to milliseconds */
#else
	/* assume clock() function returns microseconds */
	tick_count = (DWORD) (clock() / 1000L);
#endif

	if (verbose)
	{
		// Bryce
		//printf(">> get_tick_count: tick_count = %ld\n", tick_count);
	    //fflush(stdout);
	}
	return (tick_count);
}

#define DELAY_SAMPLES 10
#define DELAY_CHECK_LOOPS 10000

void calibrate_delay(void)
{
	int sample = 0;
	int count = 0;
	DWORD tick_count1 = 0L;
	DWORD tick_count2 = 0L;

	one_ms_delay = 0L;

#if PORT == WINDOWS || PORT == DOS || PORT == UNIX
	for (sample = 0; sample < DELAY_SAMPLES; ++sample)
	{
		count = 0;
		tick_count1 = get_tick_count();
		while ((tick_count2 = get_tick_count()) == tick_count1) {};
		do { delay_loop(DELAY_CHECK_LOOPS); count++; } while
			((tick_count1 = get_tick_count()) == tick_count2);
		one_ms_delay += ((DELAY_CHECK_LOOPS * (DWORD)count) /
			(tick_count1 - tick_count2));
	}

	// I'm not sure what this fudge factor is for:
	one_ms_delay /= DELAY_SAMPLES;  // DELAY_SAMPLES=10
#else
	one_ms_delay = 300000L;  //default was changed from 1000L;
#endif

	if (verbose)
	{
		// Bryce
		printf(">> calibrate_delay: one_ms_delay = %ld\n", one_ms_delay);
	    fflush(stdout);
	}

	jam_set_frequency(tck_freq);
}

char *error_text[] =
{
/* JAMC_SUCCESS            0 */ "success",
/* JAMC_OUT_OF_MEMORY      1 */ "out of memory",
/* JAMC_IO_ERROR           2 */ "file access error",
/* JAMC_SYNTAX_ERROR       3 */ "syntax error",
/* JAMC_UNEXPECTED_END     4 */ "unexpected end of file",
/* JAMC_UNDEFINED_SYMBOL   5 */ "undefined symbol",
/* JAMC_REDEFINED_SYMBOL   6 */ "redefined symbol",
/* JAMC_INTEGER_OVERFLOW   7 */ "integer overflow",
/* JAMC_DIVIDE_BY_ZERO     8 */ "divide by zero",
/* JAMC_CRC_ERROR          9 */ "CRC mismatch",
/* JAMC_INTERNAL_ERROR    10 */ "internal error",
/* JAMC_BOUNDS_ERROR      11 */ "bounds error",
/* JAMC_TYPE_MISMATCH     12 */ "type mismatch",
/* JAMC_ASSIGN_TO_CONST   13 */ "assignment to constant",
/* JAMC_NEXT_UNEXPECTED   14 */ "NEXT unexpected",
/* JAMC_POP_UNEXPECTED    15 */ "POP unexpected",
/* JAMC_RETURN_UNEXPECTED 16 */ "RETURN unexpected",
/* JAMC_ILLEGAL_SYMBOL    17 */ "illegal symbol name",
/* JAMC_VECTOR_MAP_FAILED 18 */ "vector signal name not found",
/* JAMC_USER_ABORT        19 */ "execution cancelled",
/* JAMC_STACK_OVERFLOW    20 */ "stack overflow",
/* JAMC_ILLEGAL_OPCODE    21 */ "illegal instruction code",
/* JAMC_PHASE_ERROR       22 */ "phase error",
/* JAMC_SCOPE_ERROR       23 */ "scope error",
/* JAMC_ACTION_NOT_FOUND  24 */ "action not found",
};

#define MAX_ERROR_CODE (int)((sizeof(error_text)/sizeof(error_text[0]))+1)

/************************************************************************/

int main(int argc, char **argv)
{
	// JAM Player variables:
	BOOL help = FALSE;
	BOOL error = FALSE;
	char *filename = NULL;
	long offset = 0L;
	long error_line = 0L;
	JAM_RETURN_TYPE crc_result = JAMC_SUCCESS;
	JAM_RETURN_TYPE exec_result = JAMC_SUCCESS;
	unsigned short expected_crc = 0;
	unsigned short actual_crc = 0;
	char key[33] = {0};
	char value[257] = {0};
	int exit_status = 0;
	int arg = 0;
	int exit_code = 0;
	int format_version = 0;
	time_t start_time = 0;
	time_t end_time = 0;
	int time_delta = 0;
	char *workspace = NULL;
	char *action = NULL;
	char *init_list[10];
	int init_count = 0;
	FILE *fp = NULL;
	struct stat sbuf;
	long workspace_size = 0;
	char *exit_string = NULL;
	int reset_jtag = 1;

	verbose = FALSE;

	init_list[0] = NULL;

	/* print out the version string and copyright message */
	printf("------------------------------------------\n");
	printf("Jam STAPL Player Version 2.5 (20040526)   \n");
	printf("Copyright (C) 1997-2004 Altera Corporation\n");
	printf("------------------------------------------\n");

	for (arg = 1; arg < argc; arg++)
	{
#if PORT == UNIX
		if (argv[arg][0] == '-')
#else
		if ((argv[arg][0] == '-') || (argv[arg][0] == '/'))
#endif
		{
			switch(toupper(argv[arg][1]))
			{
			case 'A':				/* set action name */
				action = &argv[arg][2];
				if (action[0] == '"') ++action;
				break;

#if PORT == WINDOWS || PORT == DOS || PORT == UNIX
			case 'C':				/* Use alternative ISP download cable */
				if(toupper(argv[arg][2]) == 'L')
					alternative_cable_l = TRUE;
				else if(toupper(argv[arg][2]) == 'X')
					alternative_cable_x = TRUE;
				break;
#endif

			case 'D':				/* initialization list */
				if (argv[arg][2] == '"')
				{
					init_list[init_count] = &argv[arg][3];
				}
				else
				{
					init_list[init_count] = &argv[arg][2];
				}
				init_list[++init_count] = NULL;
				break;

#if PORT == WINDOWS || PORT == DOS || PORT == UNIX
			case 'P':				/* set LPT port address */
				specified_lpt_port = TRUE;
				if (sscanf(&argv[arg][2], "%d", &lpt_port) != 1) error = TRUE;

				// There's some funny stuff here..
				if ((lpt_port < 1) || (lpt_port > 3)) error = TRUE;
				if (error)
				{
					if (sscanf(&argv[arg][2], "%x", &lpt_port) == 1)
					{
						if ((lpt_port == 0x278) ||
							(lpt_port == 0x27c) ||
							(lpt_port == 0x378) ||
							(lpt_port == 0x37c) ||
							(lpt_port == 0x3b8) ||
							(lpt_port == 0x3bc) ||
							(lpt_port == PORT_MCE))
						{
							error = FALSE;
							specified_lpt_addr = TRUE;
							lpt_addr = (WORD) lpt_port;
							lpt_port = 1;
						}
					}
				}
				break;
#endif

			case 'R':		/* don't reset the JTAG chain after use */
				reset_jtag = 0;
				break;

			case 'S':				/* set serial port address */
				serial_port_name = &argv[arg][2];
				specified_com_port = TRUE;
				break;

			case 'M':				/* set memory size */
				if (sscanf(&argv[arg][2], "%ld", &workspace_size) != 1)
					error = TRUE;
				if (workspace_size == 0)
					error = TRUE;
				break;

			case 'H':				/* help */
				help = TRUE;
				break;
#if  PORT == UNIX
			case 'F':
				// tck_freq can be -1 or 0, with differing effects
				// jam_set_frequency(tck_freq) called after one_ms_delay changes
				if (sscanf(&argv[arg][2], "%ld", &tck_freq) != 1)
					error = TRUE;
				break;
#endif

			case 'V':				/* verbose */
				verbose = TRUE;
				break;

			default:
				error = TRUE;
				break;
			}
		}
		else
		{
			/* it's a filename */
			if (filename == NULL)
			{
				filename = argv[arg];
			}
			else
			{
				/* error -- we already found a filename */
				error = TRUE;
			}
		}

		if (error)
		{
			fprintf(stderr, "Illegal argument: \"%s\"\n", argv[arg]);
			help = TRUE;
			error = FALSE;
		}
	}
	// End of 'for' loop parser

	// Options checking..
#if PORT == WINDOWS || PORT == DOS || PORT == UNIX
	if (specified_lpt_port && specified_com_port)
	{
		fprintf(stderr, "Error:  -s and -p options may not be used together\n\n");
		help = TRUE;
	}
#endif

	// Print out the options
	if (help || (filename == NULL))
	{
		fprintf(stderr, "Usage:  jam [options] <filename>\n");
		fprintf(stderr, "\nAvailable options:\n");
		fprintf(stderr, "    -h          : show help message\n");
		fprintf(stderr, "    -v          : show verbose messages\n");
		fprintf(stderr, "    -a<action>  : specify action name (Jam STAPL)\n");
		fprintf(stderr, "    -d<var=val> : initialize variable to specified value (Jam 1.1)\n");
		fprintf(stderr, "    -d<proc=1>  : enable optional procedure (Jam STAPL)\n");
		fprintf(stderr, "    -d<proc=0>  : disable recommended procedure (Jam STAPL)\n");
#if PORT == WINDOWS || PORT == DOS
		fprintf(stderr, "    -p<port>    : parallel port number or address (for ByteBlaster)\n");
		fprintf(stderr, "    -c<cable>   : alternative download cable compatibility: -cl or -cx\n");
#endif
#if  PORT == UNIX
		fprintf(stderr, "    -f<freq>    : TCK frequency in kHz (max = 10000)\n");
		fprintf(stderr, "    -p<port>    : parallel port number or device (/dev/parport*) (for ByteBlaster: 0x378)\n");
		fprintf(stderr, "    -c<cable>   : alternative download cable compatibility: -cl or -cx\n");
#endif

		fprintf(stderr, "    -s<port>    : serial port name (for BitBlaster)\n");
		fprintf(stderr, "    -r          : don't reset JTAG TAP after use\n");
		exit_status = 1;
	}
	else if ((workspace_size > 0) &&
		((workspace = (char *) jam_malloc((size_t) workspace_size)) == NULL))
	{
		fprintf(stderr, "Error: can't allocate memory (%d Kbytes)\n",
			(int) (workspace_size / 1024L));
		exit_status = 1;
	}
	else if (access(filename, 0) != 0)
	{
		fprintf(stderr, "Error: can't access file \"%s\"\n", filename);
		exit_status = 1;
	}
	else
	{
		// Get length of JAM file
		if (stat(filename, &sbuf) == 0) file_length = sbuf.st_size;

		if ((fp = fopen(filename, "rb")) == NULL)
		{
			fprintf(stderr, "Error: can't open file \"%s\"\n", filename);
			exit_status = 1;
		}
		else
		{
			// Read the entire JAM file into a buffer called 'file_buffer'..
#if PORT == DOS
			int pages = 1 + (int) (file_length >> 14L);
			int page;
			file_buffer = (char **) jam_malloc((size_t) (pages * sizeof(char *)));
			for (page = 0; page < pages; ++page)
			{
				// Allocate enough 16K blocks to store the file
				file_buffer[page] = (char *) jam_malloc (0x4000);
				if (file_buffer[page] == NULL)
				{
					// Flag the allocation error and break out of the loop
					file_buffer = NULL;
					page = pages;
				}
			}
#else
			file_buffer = (char *) jam_malloc((size_t) file_length);
#endif
			if (file_buffer == NULL)
			{
				fprintf(stderr, "Error: can't allocate memory (%d Kbytes)\n",
					(int) (file_length / 1024L));
				exit_status = 1;
			}
			else
			{
#if PORT == DOS
				int pages = 1 + (int) (file_length >> 14L);
				int page;
				size_t page_size = 0x4000;
				for (page = 0; (page < pages) && (exit_status == 0); ++page)
				{
					if (page == (pages - 1))
					{
						// The last page may not be a full 16K bytes
						page_size = (size_t) (file_length & 0x3fffL);
					}
					if (fread(file_buffer[page], 1, page_size, fp) != page_size)
					{
						fprintf(stderr, "Error reading file \"%s\"\n", filename);
						exit_status = 1;
					}
				}
#else
				if (fread(file_buffer, 1, (size_t) file_length, fp) !=
					(size_t) file_length)
				{
					fprintf(stderr, "Error reading file \"%s\"\n", filename);
					exit_status = 1;
				}
#endif
			}

			fclose(fp);
		}
		// ..Done reading the entire JAM file into buffer


		if (exit_status == 0)
		{

#if PORT == WINDOWS
			// Get Operating System type
			windows_nt = !(GetVersion() & 0x80000000);
#endif

			// Before exercising the JTAG chain, calibrate the TCK frequency
			calibrate_delay();

			// Check the integrity of the JAM file
			crc_result = jam_check_crc(
#if PORT==DOS
				0L, 0L,
#else
				file_buffer, file_length,
#endif
				&expected_crc, &actual_crc);

			if (verbose || (crc_result == JAMC_CRC_ERROR))
			{
				switch (crc_result)
				{
				case JAMC_SUCCESS:
					printf("CRC matched: CRC value = %04X\n", actual_crc);
					break;

				case JAMC_CRC_ERROR:
					printf("CRC mismatch: expected %04X, actual %04X\n",
						expected_crc, actual_crc);
					break;

				case JAMC_UNEXPECTED_END:
					printf("Expected CRC not found, actual CRC value = %04X\n",
						actual_crc);
					break;

				default:
					printf("CRC function returned error code %d\n", crc_result);
					break;
				}
			}

			// Print out the NOTE fields from the JAM file
			if (verbose)
			{
				while (jam_get_note(
#if PORT==DOS
					0L, 0L,
#else
					file_buffer, file_length,
#endif
					&offset, key, value, 256) == 0)
				{
					printf("NOTE \"%s\" = \"%s\"\n", key, value);
				}
			}

			if (lpt_addr == PORT_MCE) {
				//------------------------------------------------------
				// Open MCE connections
				//------------------------------------------------------

				// Get a library context structure (cheap)
				mce = mcelib_create();

				// Load MCE config information ("xml")
				if (mceconfig_open(mce, CONFIG_FILE, NULL) != 0) {
					fprintf(stderr, "Failed to load MCE configuration file %s.\n",
						CONFIG_FILE);
					return 1;
				}

				// Connect to an mce_cmd device.
				if (mcecmd_open(mce, CMD_DEVICE) != 0) {
					fprintf(stderr, "Failed to open %s.\n", CMD_DEVICE);;
					return 1;
				}

				//------------------------------------------------------------------
				// Look up ID's
				//------------------------------------------------------------------
				// Lookup "cc led"
				if ((mce_error=mcecmd_load_param(mce, &cc_fw_rev, "cc", "fw_rev")) != 0) {
					fprintf(stderr, "Lookup failed.\n");
					return 1;
				}
				//mce_param_t cc_jtag0;
				if ((mce_error=mcecmd_load_param(mce, &cc_jtag0, "cc", "jtag0")) != 0) {
					fprintf(stderr, "Lookup failed.\n");
					return 1;
				}
				//mce_param_t cc_jtag1;
				if ((mce_error=mcecmd_load_param(mce, &cc_jtag1, "cc", "jtag1")) != 0) {
					fprintf(stderr, "Lookup failed.\n");
					return 1;
				}
				//mce_param_t cc_jtag2;
				if ((mce_error=mcecmd_load_param(mce, &cc_jtag2, "cc", "jtag2")) != 0) {
					fprintf(stderr, "Lookup failed.\n");
					return 1;
				}



				// Read.
				mce_error = mcecmd_read_block(mce,
						       &cc_fw_rev  /* mce_param_t for the card/para */,
						       1            /* number of words to read, per card */,
						       mce_data         /* buffer for the words */);

				if (mce_error != 0) {
					fprintf(stderr, "MCE command failed: '%s'\n",
						mcelib_error_string(mce_error));
					return 1;
				}

				if (verbose) {
					printf(">> rb cc fw_rev = %u (%#x)\n", mce_data[0], mce_data[0]);
				}

//				// Try to read 2 words, this will fail.
//				// Note that we are re-using cc_led; it remains valid.
//				mce_error = mcecmd_read_block(mce,
//						       &cc_led  /* mce_param_t for the card/para */,
//						       2            /* number of words to read, per card */,
//						       mce_data         /* buffer for the words */);
//
//				printf("Reading 2 words from rc1 fw_rev returns mce_error -%#x and message '%s'\n",
//				       -mce_error, mcelib_error_string(mce_error));
//
//				// Multi-value read:
//				mce_param_t gainp0;
//				if ( mcecmd_load_param(mce, &gainp0, "rc1", "gainp0") != 0) {
//					fprintf(stdout, "Couldn't load gainp0.\n");
//					return 1;
//				}
//
//				// Number of values in in gainp0.param.count
//				mce_num_param = gainp0.param.count;
//				mce_error = mcecmd_read_block(mce, &gainp0, mce_num_param, mce_data);
//				printf("rc1 gainp0: ");
//				print_u32(mce_data, mce_num_param);
//
//				// Manipulate
//				printf("Replacing with 10*i...\n");
//				for (int i=0; i<mce_num_param; i++) {
//					mce_data[i] = 10*i;
//				}
//				mce_error = mcecmd_write_block(mce, &gainp0, mce_num_param, mce_data);
//
//				mce_error = mcecmd_read_block(mce, &gainp0, mce_num_param, mce_data);
//				printf("rc1 gainp0: ");
//				print_u32(mce_data, mce_num_param);
//
//				// Manipulate single elements
//				printf("Setting elements 3 and 12...\n");
//				mce_error = mcecmd_write_element(mce, &gainp0, 3, 66);
//				mce_error = mcecmd_write_element(mce, &gainp0, 12, 88);
//
//				mce_error = mcecmd_read_block(mce, &gainp0, mce_num_param, mce_data);
//				printf("rc1 gainp0: ");
//				print_u32(mce_data, mce_num_param);
//
//				/*
//				  Sys: multi-card read abstraction; other contents of mce_param_t structure
//				*/
//
//				mce_param_t sys_row_len;
//				if (mcecmd_load_param(mce, &sys_row_len, "sys", "row_len") != 0) {
//					fprintf(stderr, "Couldn't load 'sys row_len'\n");
//					return 1;
//				}
//
//				// The natural 'size' of the parameter is obtained like this:
//				int n_write = sys_row_len.param.count;
//
//				// On reads, some parameters query multiple cards and return
//                    // n_cards * n_write data elements.
//				int n_read  = mcecmd_read_size(&sys_row_len, n_write);
//
//				// mce_param_t contains much useful information...
//				printf("'%s %s' operates on %i cards\n",
//				       sys_row_len.card.name, sys_row_len.param.name,
//				       sys_row_len.card.card_count);
//
//				// Note that we can pass "-1" as the count to query for all data
//				//  (i.e. -1 should return the same number of data as n_write)
//				mce_error = mcecmd_read_block(mce, &sys_row_len, -1, mce_data);
//				printf(" mce_data: ");
//				print_u32(mce_data, n_read);
//
//				// Let's change those
//				printf("Set to 50...\n");
//				more_data[0] = 50;
//				mce_error = mcecmd_write_block(mce, &sys_row_len, -1, more_data);
//
//				mce_error = mcecmd_read_block(mce, &sys_row_len, -1, more_data);
//				printf(" mce_data: ");
//				print_u32(more_data, n_read);
//
//				// Restore...
//				printf("Restore...\n");
//				mce_error = mcecmd_write_block(mce, &sys_row_len, -1, mce_data);
//
//				mce_error = mcecmd_read_block(mce, &sys_row_len, -1, more_data);
//				printf(" mce_data: ");
//				print_u32(more_data, n_read);
			}
			else {
				if (verbose) {
					printf(">> main: Using Byte Blaster");
				}
			}

			// Execute the JAM program
			time(&start_time);
			exec_result = jam_execute(
#if PORT==DOS
				0L, 0L,
#else
				file_buffer, file_length,
#endif
				workspace, workspace_size, action, init_list,
				reset_jtag, &error_line, &exit_code, &format_version);
			time(&end_time);

			// If the execution was successful
			if (exec_result == JAMC_SUCCESS)
			{
				if (format_version == 2)
				{
					switch (exit_code)
					{
					case  0: exit_string = "Success"; break;
					case  1: exit_string = "Checking chain failure"; break;
					case  2: exit_string = "Reading IDCODE failure"; break;
					case  3: exit_string = "Reading USERCODE failure"; break;
					case  4: exit_string = "Reading UESCODE failure"; break;
					case  5: exit_string = "Entering ISP failure"; break;
					case  6: exit_string = "Unrecognized device"; break;
					case  7: exit_string = "Device revision is not supported"; break;
					case  8: exit_string = "Erase failure"; break;
					case  9: exit_string = "Device is not blank"; break;
					case 10: exit_string = "Device programming failure"; break;
					case 11: exit_string = "Device verify failure"; break;
					case 12: exit_string = "Read failure"; break;
					case 13: exit_string = "Calculating checksum failure"; break;
					case 14: exit_string = "Setting security bit failure"; break;
					case 15: exit_string = "Querying security bit failure"; break;
					case 16: exit_string = "Exiting ISP failure"; break;
					case 17: exit_string = "Performing system test failure"; break;
					default: exit_string = "Unknown exit code"; break;
					}
				}
				else
				{
					switch (exit_code)
					{
					case 0: exit_string = "Success"; break;
					case 1: exit_string = "Illegal initialization values"; break;
					case 2: exit_string = "Unrecognized device"; break;
					case 3: exit_string = "Device revision is not supported"; break;
					case 4: exit_string = "Device programming failure"; break;
					case 5: exit_string = "Device is not blank"; break;
					case 6: exit_string = "Device verify failure"; break;
					case 7: exit_string = "SRAM configuration failure"; break;
					default: exit_string = "Unknown exit code"; break;
					}
				}

				printf("Exit code = %d... %s\n", exit_code, exit_string);
			}
			// Otherwise, if the action was not found in the JAM file
			else if ((format_version == 2) &&
				(exec_result == JAMC_ACTION_NOT_FOUND))
			{
				if ((action == NULL) || (*action == '\0'))
				{
					printf("Error: no action specified for Jam file.\nProgram terminated.\n");
				}
				else
				{
					printf("Error: action \"%s\" is not supported for this Jam file.\nProgram terminated.\n", action);
				}
			}
			// Otherwise, if there was an KNOWN execution error
			else if (exec_result < MAX_ERROR_CODE)
			{
				printf("Error on line %ld: %s.\nProgram terminated.\n",
					error_line, error_text[exec_result]);
			}
			// Otherwise, if there was an UNKNOWN execution error
			else
			{
				printf("Unknown error code %d\n", exec_result);
			}

			// Print out elapsed time
			if (verbose)
			{
				time_delta = (int) (end_time - start_time);
				printf("Elapsed time = %02u:%02u:%02u\n",
					time_delta / 3600,			/* hours */
					(time_delta % 3600) / 60,	/* minutes */
					time_delta % 60);			/* seconds */
			}
		}
	}

	// Close hardware ports and disable MCE FPGA JTAG access
	if (jtag_hardware_initialized) close_jtag_hardware();

	// Close MCE access
	if (lpt_addr == PORT_MCE) mcelib_destroy(mce);

	// Release allocated memory
	if (workspace != NULL) jam_free(workspace);
	if (file_buffer != NULL) jam_free(file_buffer);

	#if defined(MEM_TRACKER)
	if (verbose)
	{
#if defined(USE_STATIC_MEMORY)
		fprintf(stdout, "Memory Usage Info: static memory size = %ud (%dKB)\n", N_STATIC_MEMORY_BYTES, N_STATIC_MEMORY_KBYTES);
#endif /* USE_STATIC_MEMORY */
		fprintf(stdout, "Memory Usage Info: peak memory usage = %ud (%dKB)\n", peak_memory_usage, (peak_memory_usage + 1023) / 1024);
		fprintf(stdout, "Memory Usage Info: peak allocations = %d\n", peak_allocations);
#if defined(USE_STATIC_MEMORY)
		if ((n_bytes_allocated - n_bytes_not_recovered) != 0)
		{
			fprintf(stdout, "Memory Usage Info: bytes still allocated = %d (%dKB)\n", (n_bytes_allocated - n_bytes_not_recovered), ((n_bytes_allocated - n_bytes_not_recovered) + 1023) / 1024);
		}
#else /* USE_STATIC_MEMORY */
		if (n_bytes_allocated != 0)
		{
			fprintf(stdout, "Memory Usage Info: bytes still allocated = %d (%dKB)\n", n_bytes_allocated, (n_bytes_allocated + 1023) / 1024);
		}
#endif /* USE_STATIC_MEMORY */
		if (n_allocations != 0)
		{
			fprintf(stdout, "Memory Usage Info: allocations not freed = %d\n", n_allocations);
		}
	}
#endif /* MEM_TRACKER */


	return (exit_status);
}

#if PORT==WINDOWS
#ifndef __BORLANDC__
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*	SEARCH_DYN_DATA
*
*	Searches recursively in Windows 95/98 Registry for parallel port info
*	under HKEY_DYN_DATA registry key.  Called by search_local_machine().
*/
void search_dyn_data
(
	char *dd_path,
	char *hardware_key,
	int lpt
)
{
	DWORD index;
	DWORD size;
	DWORD type;
	LONG result;
	HKEY key;
	int length;
	WORD address;
	char buffer[1024];
	FILETIME last_write = {0};
	WORD *word_ptr;
	int i;

	length = strlen(dd_path);

	if (RegOpenKeyEx(
		HKEY_DYN_DATA,
		dd_path,
		0L,
		KEY_READ,
		&key)
		== ERROR_SUCCESS)
	{
		size = 1023;

		if (RegQueryValueEx(
			key,
			"HardWareKey",
			NULL,
			&type,
			(unsigned char *) buffer,
			&size)
			== ERROR_SUCCESS)
		{
			if ((type == REG_SZ) && (stricmp(buffer, hardware_key) == 0))
			{
				size = 1023;

				if (RegQueryValueEx(
					key,
					"Allocation",
					NULL,
					&type,
					(unsigned char *) buffer,
					&size)
					== ERROR_SUCCESS)
				{
					/*
					*	By "inspection", I have found five cases: size 32, 48,
					*	56, 60, and 80 bytes.  The port address seems to be
					*	located at different offsets in the buffer for these
					*	five cases, as shown below.  If a valid port address
					*	is not found, or the size is not one of these known
					*	sizes, then I search through the entire buffer and
					*	look for a value which is a valid port address.
					*/

					word_ptr = (WORD *) buffer;

					if ((type == REG_BINARY) && (size == 32))
					{
						address = word_ptr[10];
					}
					else if ((type == REG_BINARY) && (size == 48))
					{
						address = word_ptr[18];
					}
					else if ((type == REG_BINARY) && (size == 56))
					{
						address = word_ptr[22];
					}
					else if ((type == REG_BINARY) && (size == 60))
					{
						address = word_ptr[24];
					}
					else if ((type == REG_BINARY) && (size == 80))
					{
						address = word_ptr[24];
					}
					else address = 0;

					/* if not found, search through entire buffer */
					i = 0;
					while ((i < (int) (size / 2)) &&
						(address != 0x278) &&
						(address != 0x27C) &&
						(address != 0x378) &&
						(address != 0x37C) &&
						(address != 0x3B8) &&
						(address != 0x3BC))
					{
						if ((word_ptr[i] == 0x278) ||
							(word_ptr[i] == 0x27C) ||
							(word_ptr[i] == 0x378) ||
							(word_ptr[i] == 0x37C) ||
							(word_ptr[i] == 0x3B8) ||
							(word_ptr[i] == 0x3BC))
						{
							address = word_ptr[i];
						}
						++i;
					}

					if ((address == 0x278) ||
						(address == 0x27C) ||
						(address == 0x378) ||
						(address == 0x37C) ||
						(address == 0x3B8) ||
						(address == 0x3BC))
					{
						lpt_addresses_from_registry[lpt] = address;
					}
				}
			}
		}

		index = 0;

		do
		{
			size = 1023;

			result = RegEnumKeyEx(
				key,
				index++,
				buffer,
				&size,
				NULL,
				NULL,
				NULL,
				&last_write);

			if (result == ERROR_SUCCESS)
			{
				dd_path[length] = '\\';
				dd_path[length + 1] = '\0';
				strcpy(&dd_path[length + 1], buffer);

				search_dyn_data(dd_path, hardware_key, lpt);

				dd_path[length] = '\0';
			}
		}
		while (result == ERROR_SUCCESS);

		RegCloseKey(key);
	}
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*	SEARCH_LOCAL_MACHINE
*
*	Searches recursively in Windows 95/98 Registry for parallel port info
*	under HKEY_LOCAL_MACHINE\Enum.  When parallel port is found, calls
*	search_dyn_data() to get the port address.
*/
void search_local_machine
(
	char *lm_path,
	char *dd_path
)
{
	DWORD index;
	DWORD size;
	DWORD type;
	LONG result;
	HKEY key;
	int length;
	char buffer[1024];
	FILETIME last_write = {0};

	length = strlen(lm_path);

	if (RegOpenKeyEx(
		HKEY_LOCAL_MACHINE,
		lm_path,
		0L,
		KEY_READ,
		&key)
		== ERROR_SUCCESS)
	{
		size = 1023;

		if (RegQueryValueEx(
			key,
			"PortName",
			NULL,
			&type,
			(unsigned char *) buffer,
			&size)
			== ERROR_SUCCESS)
		{
			if ((type == REG_SZ) &&
				(size == 5) &&
				(buffer[0] == 'L') &&
				(buffer[1] == 'P') &&
				(buffer[2] == 'T') &&
				(buffer[3] >= '1') &&
				(buffer[3] <= '4') &&
				(buffer[4] == '\0'))
			{
				/* we found the entry in HKEY_LOCAL_MACHINE, now we need to */
				/* find the corresponding entry under HKEY_DYN_DATA.  */
				/* add 5 to lm_path to skip over "Enum" and backslash */
				search_dyn_data(dd_path, &lm_path[5], (buffer[3] - '1'));
			}
		}

		index = 0;

		do
		{
			size = 1023;

			result = RegEnumKeyEx(
				key,
				index++,
				buffer,
				&size,
				NULL,
				NULL,
				NULL,
				&last_write);

			if (result == ERROR_SUCCESS)
			{
				lm_path[length] = '\\';
				lm_path[length + 1] = '\0';
				strcpy(&lm_path[length + 1], buffer);

				search_local_machine(lm_path, dd_path);

				lm_path[length] = '\0';
			}
		}
		while (result == ERROR_SUCCESS);

		RegCloseKey(key);
	}
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*	GET_LPT_ADDRESSES_FROM_REGISTRY
*
*	Searches Win95/98 registry recursively to get I/O port addresses for
*	parallel ports.
*/
void get_lpt_addresses_from_registry()
{
	char lm_path[1024];
	char dd_path[1024];

	strcpy(lm_path, "Enum");
	strcpy(dd_path, "Config Manager");
	search_local_machine(lm_path, dd_path);
}
#endif
#endif

void initialize_jtag_hardware()
{
	// If programming via a serial port
	if (specified_com_port)
	{
		com_port = open(serial_port_name, O_RDWR);
		if (com_port == -1)
		{
			fprintf(stderr, "Error: can't open serial port \"%s\"\n",
				serial_port_name);
		}
		else
		{
			int i = 0, result = 0;
			char data = 0;

			data = 0x7e;
			write(com_port, &data, 1);

			for (i = 0; (i < 100) && (result != 1); ++i)
			{
				result = read(com_port, &data, 1);
			}

			if (result == 1)
			{
				data = 0x70; write(com_port, &data, 1); /* TDO echo off */
				data = 0x72; write(com_port, &data, 1); /* auto LEDs off */
				data = 0x74; write(com_port, &data, 1); /* ERROR LED off */
				data = 0x76; write(com_port, &data, 1); /* DONE LED off */
				data = 0x60; write(com_port, &data, 1); /* signals low */
			}
			else
			{
				fprintf(stderr, "Error: BitBlaster is not responding on %s\n", serial_port_name);
				close(com_port);
				com_port = -1;
			}
		}
	}
	// If not programming via a serial port, then check the parallel port permissions and setup the Byte Blaster
	else
	{
#if PORT == WINDOWS || PORT == DOS || PORT == UNIX

// Begin WINDOWS..
#if PORT == WINDOWS
		if (windows_nt)
		{
			initialize_nt_driver();
		}
		else
		{
#ifdef __BORLANDC__
			fprintf(stderr, "Error: parallel port access is not available\n");
#else
			if (!specified_lpt_addr)
			{
				get_lpt_addresses_from_registry();

				lpt_addr = 0;

				if (specified_lpt_port)
				{
					lpt_addr = lpt_addresses_from_registry[lpt_port - 1];
				}

				if (lpt_addr == 0)
				{
					if (lpt_addresses_from_registry[3] != 0)
						lpt_addr = lpt_addresses_from_registry[3];
					if (lpt_addresses_from_registry[2] != 0)
						lpt_addr = lpt_addresses_from_registry[2];
					if (lpt_addresses_from_registry[1] != 0)
						lpt_addr = lpt_addresses_from_registry[1];
					if (lpt_addresses_from_registry[0] != 0)
						lpt_addr = lpt_addresses_from_registry[0];
				}

				if (lpt_addr == 0)
				{
					if (specified_lpt_port)
					{
						lpt_addr = lpt_addr_table[lpt_port - 1];
					}
					else
					{
						lpt_addr = lpt_addr_table[0];
					}
				}
			}
			initial_lpt_ctrl = windows_nt ? 0x0c : read_byteblaster(PORT2);
#endif
		}
#endif
// ..End WINDOWS

#if PORT == DOS
		// Read word at specific memory address to get the LPT port address
		WORD *bios_address = (WORD *) 0x00400008;

		if (!specified_lpt_addr)
		{
			lpt_addr = bios_address[lpt_port - 1];

			if ((lpt_addr != 0x278) &&
				(lpt_addr != 0x27c) &&
				(lpt_addr != 0x378) &&
				(lpt_addr != 0x37c) &&
				(lpt_addr != 0x3b8) &&
				(lpt_addr != 0x3bc) &&
				(lpt_addr != PORT_MCE))
			{
				lpt_addr = lpt_addr_table[lpt_port - 1];
			}
		}
		initial_lpt_ctrl = read_byteblaster(PORT2);
#endif

#if PORT == UNIX
		if (verbose)
		{
			// Bryce
//			fprintf(stderr, ">> initialize_jtag_hardware: Checking parallel port %#x permissions..\n", lpt_addr);
//			fflush(stderr);
			printf(">> initialize_jtag_hardware: Checking parallel port %#x permissions..\n", lpt_addr);
			fflush(stdout);
		}

		if (ioperm(lpt_addr, 3, OPEN)!= 0)
		{
			// Bryce
			fprintf(stderr, ">> initialize_jtag_hardware: Error opening parallel port %#x!\n", lpt_addr);
			fflush(stderr);
			exit(1);
		}
		else
		{
			if (verbose)
			{
				// Bryce
//				fprintf(stderr, ">> initialize_jtag_hardware: Parallel port %#x is open.\n", lpt_addr);
//				fflush(stderr);
				printf(">> initialize_jtag_hardware: Parallel port %#x is open.\n", lpt_addr);
				fflush(stdout);
			}
		}
#endif
		/* set AUTO-FEED low to enable ByteBlaster (value to port inverted): */
		/* set DIRECTION low for data output from parallel port */
		// Enable the JTAG Chain
		// In UNIX, initial_lpt_ctrl = "00000000"
		write_byteblaster(PORT2, (initial_lpt_ctrl | 0x02) & 0xDF);
		if (verbose)
		{
			// Bryce
			printf(">> initialize_jtag_hardware: JTAG chain enabled = %#x.\n", (initial_lpt_ctrl | 0x02) & 0xDF);
			fflush(stdout);
		}
#endif
	}
}

void close_jtag_hardware()
{
	// If programming via a serial port
	if (specified_com_port)
	{
		if (com_port != -1) close(com_port);
	}
	else
	{
#if PORT == WINDOWS || PORT == DOS || PORT == UNIX
		/* set AUTO-FEED high to disable ByteBlaster */
		// Disable the JTAG Chain
		write_byteblaster(PORT2, initial_lpt_ctrl & 0xfd);
		if (verbose)
		{
			// Bryce
			printf(">> close_jtag_hardware: JTAG chain disabled = %#x.\n", initial_lpt_ctrl & 0xfd);
			fflush(stdout);
		}

#if PORT == WINDOWS
		if (windows_nt && (nt_device_handle != INVALID_HANDLE_VALUE))
		{
			if (port_io_count > 0) flush_ports();

			CloseHandle(nt_device_handle);
		}
#endif

#if  PORT == UNIX
		if (verbose) {
			printf(">> close_jtag_hardware: Closing port %#x..\n", lpt_addr);
			fflush(stdout);
		}

		if (ioperm(lpt_addr, 3, CLOSED)!= 0) {
			fprintf(stderr, ">> close_jtag_hardware: Error closing parallel port %#x.\n", lpt_addr);
			fflush(stderr);
		}
		else {
			if (verbose) {
				printf(">> close_jtag_hardware: Parallel port %#x is closed.\n", lpt_addr);
				fflush(stdout);
			}
		}
#endif

#endif
	}
}

#if PORT == WINDOWS
/**************************************************************************/
/*                                                                        */

BOOL initialize_nt_driver()

/*                                                                        */
/*  Uses CreateFile() to open a connection to the Windows NT device       */
/*  driver.                                                               */
/*                                                                        */
/**************************************************************************/
{
	BOOL status = FALSE;

	ULONG buffer[1];
	ULONG returned_length = 0;
	char nt_lpt_str[] = { '\\', '\\', '.', '\\',
		'A', 'L', 'T', 'L', 'P', 'T', '1', '\0' };


	nt_lpt_str[10] = (char) ('1' + (lpt_port - 1));

	nt_device_handle = CreateFile(
		nt_lpt_str,
		GENERIC_READ | GENERIC_WRITE,
		0,
		NULL,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		NULL);

	if (nt_device_handle == INVALID_HANDLE_VALUE)
	{
		fprintf(stderr,
			"I/O error:  cannot open device %s\nCheck port number and device driver installation",
			nt_lpt_str);
	}
	else
	{
		if (DeviceIoControl(
			nt_device_handle,			/* Handle to device */
			PGDC_IOCTL_GET_DEVICE_INFO_PP,	/* IO Control code */
			(ULONG *)NULL,					/* Buffer to driver. */
			0,								/* Length of buffer in bytes. */
			&buffer,						/* Buffer from driver. */
			sizeof(ULONG),					/* Length of buffer in bytes. */
			&returned_length,				/* Bytes placed in data_buffer. */
			NULL))							/* Wait for operation to complete */
		{
			if (returned_length == sizeof(ULONG))
			{
				if (buffer[0] == PGDC_HDLC_NTDRIVER_VERSION)
				{
					status = TRUE;
				}
				else
				{
					fprintf(stderr,
						"I/O error:  device driver %s is not compatible\n(Driver version is %lu, expected version %lu.\n",
						nt_lpt_str,
						(unsigned long) buffer[0],
						(unsigned long) PGDC_HDLC_NTDRIVER_VERSION);
				}
			}
			else
			{
				fprintf(stderr, "I/O error:  device driver %s is not compatible.\n",
					nt_lpt_str);
			}
		}

		if (!status)
		{
			CloseHandle(nt_device_handle);
			nt_device_handle = INVALID_HANDLE_VALUE;
		}
	}

	if (!status)
	{
		/* error message already given */
		exit(1);
	}

	return (status);
}
#endif

#if PORT == WINDOWS || PORT == DOS || PORT == UNIX
/**************************************************************************/
/*                                                                        */

void write_byteblaster
(
	int port,
	int data
)

/*                                                                        */
/**************************************************************************/
{
  //	printf("write\n");
#if PORT == WINDOWS
	BOOL status = FALSE;

	int returned_length = 0;
	int buffer[2];


	if (windows_nt)
	{
		/*
		*	On Windows NT, access hardware through device driver
		*/
		if (port == 0)
		{
			port_io_buffer[port_io_count].data = (USHORT) data;
			port_io_buffer[port_io_count].command = PGDC_WRITE_PORT;
			++port_io_count;

			if (port_io_count >= PORT_IO_BUFFER_SIZE) flush_ports();
		}
		else
		{
			if (port_io_count > 0) flush_ports();

			buffer[0] = port;
			buffer[1] = data;

			status = DeviceIoControl(
				nt_device_handle,			/* Handle to device */
				PGDC_IOCTL_WRITE_PORT_PP,	/* IO Control code for write */
				(ULONG *)&buffer,			/* Buffer to driver. */
				2 * sizeof(int),			/* Length of buffer in bytes. */
				(ULONG *)NULL,				/* Buffer from driver.  Not used. */
				0,							/* Length of buffer in bytes. */
				(ULONG *)&returned_length,	/* Bytes returned.  Should be zero. */
				NULL);						/* Wait for operation to complete */

			if ((!status) || (returned_length != 0))
			{
				fprintf(stderr, "I/O error:  Cannot access ByteBlaster hardware\n");
				CloseHandle(nt_device_handle);
				exit(1);
			}
		}
	}
	else
#endif
	{
		if (verbose) {
//			printf("TDI = %#x (port=%d)\n", data, port);
//			fflush(stdout);
		}

		if (lpt_addr == PORT_MCE) {
			mce_data[0] = data; // WORD => u32

			if (port == PORT0) {
				mce_error = mcecmd_write_block(mce,
						       &cc_jtag0  /* mce_param_t for the card/para */,
						       1          /* number of words to write, per card */,
						       mce_data   /* buffer for the words */);
			}
			else if (port == PORT1) {
				// Not used for writing TDI
			}
			else if (port == PORT2) { //port == PORT2
				mce_error = mcecmd_write_block(mce,
						       &cc_jtag2  /* mce_param_t for the card/para */,
						       1          /* number of words to write, per card */,
						       mce_data   /* buffer for the words */);
			}
			else {
				printf(">> write_byteblaster: Write error.");
		    }
		}
		else {
			outb(data, (port + lpt_addr));
		}
	}
}

/**************************************************************************/
/*                                                                        */

int read_byteblaster
(
	int port
)

/*                                                                        */
/**************************************************************************/
{
	int data = 0;
	//	printf("read\n");
#if PORT == WINDOWS

	BOOL status = FALSE;

	int returned_length = 0;


	if (windows_nt)
	{
		/* flush output cache buffer before reading from device */
		if (port_io_count > 0) flush_ports();

		/*
		*	On Windows NT, access hardware through device driver
		*/
		status = DeviceIoControl(
			nt_device_handle,			/* Handle to device */
			PGDC_IOCTL_READ_PORT_PP,	/* IO Control code for Read */
			(ULONG *)&port,				/* Buffer to driver. */
			sizeof(int),				/* Length of buffer in bytes. */
			(ULONG *)&data,				/* Buffer from driver. */
			sizeof(int),				/* Length of buffer in bytes. */
			(ULONG *)&returned_length,	/* Bytes placed in data_buffer. */
			NULL);						/* Wait for operation to complete */

		if ((!status) || (returned_length != sizeof(int)))
		{
			fprintf(stderr, "I/O error:  Cannot access ByteBlaster hardware\n");
			CloseHandle(nt_device_handle);
			exit(1);
		}
	}
	else
#endif
	{
		if (lpt_addr == PORT_MCE) {
			if (port == PORT0) {
				// Not used for reading TDO
			}
			else if (port == PORT1) {
				mce_error = mcecmd_read_block(mce,
						       &cc_jtag1  /* mce_param_t for the card/para */,
						       1          /* number of words to read, per card */,
						       mce_data   /* buffer for the words */);

				// data is a WORD.  Is this cast OK?  Yes.
				data = mce_data[0]; //u32 => WORD
			}
			else if (port == PORT2) {
				// Not used for reading TDO
			}
			else {
				printf(">> read_byteblaster: Read error.");
		    }
		}
		else {
			data = inb(port + lpt_addr);
		}

		if (verbose)
		{
			// Bryce
			// printf("TDO: %#x\n", data);
//			printf("TDO: %#x (port=%d)\n", data, port);
//		    fflush(stdout);
		}
	}

	return (data & 0xff);
}

#if PORT == WINDOWS
void flush_ports(void)
{
	ULONG n_writes = 0L;
	BOOL status;

	status = DeviceIoControl(
		nt_device_handle,			/* handle to device */
		PGDC_IOCTL_PROCESS_LIST_PP,	/* IO control code */
		(LPVOID)port_io_buffer,		/* IN buffer (list buffer) */
		port_io_count * sizeof(struct PORT_IO_LIST_STRUCT),/* length of IN buffer in bytes */
		(LPVOID)port_io_buffer,	/* OUT buffer (list buffer) */
		port_io_count * sizeof(struct PORT_IO_LIST_STRUCT),/* length of OUT buffer in bytes */
		&n_writes,					/* number of writes performed */
		0);							/* wait for operation to complete */

	if ((!status) || ((port_io_count * sizeof(struct PORT_IO_LIST_STRUCT)) != n_writes))
	{
		fprintf(stderr, "I/O error:  Cannot access ByteBlaster hardware\n");
		CloseHandle(nt_device_handle);
		exit(1);
	}

	port_io_count = 0;
}
#endif /* PORT == WINDOWS */
#endif /* PORT == WINDOWS || PORT == DOS */

#if !defined (DEBUG)
#pragma optimize ("ceglt", off)
#endif

void delay_loop(long count)
{
	while (count != 0L) count--;
}
