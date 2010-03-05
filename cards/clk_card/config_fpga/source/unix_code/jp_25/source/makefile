
#	Module:			makefile
#
#					Copyright (C) Altera Corporation 1997-1999
#
#	Description:	Makefile for JAM Interpreter
#

TARGET=jam
CC=gcc
LIB=-L/usr/local/lib -lmcecmd -lconfig -lmaslog -lpthread
CFLAGS = -Wall -std=c99 -I/usr/local/include

OBJS = \
	jamstub.o \
	jamexec.o \
	jamnote.o \
	jamcrc.o \
	jamsym.o \
	jamstack.o \
	jamheap.o \
	jamarray.o \
	jamcomp.o \
	jamjtag.o \
	jamutil.o \
	jamexp.o

.c.o :
	gcc $(CFLAGS) -c -I. $<

# LINK: add appropriate linker command here

$(TARGET) : $(OBJS)
	gcc $(OBJS) -o $(TARGET) $(LIB)

clean:
	rm *.o $(TARGET)

# Dependencies:

jamstub.o : \
	jamstub.c \
	jamport.h \
	jamexprt.h

jamexec.o : \
	jamexec.c \
	jamport.h \
	jamexprt.h \
	jamdefs.h \
	jamexec.h \
	jamutil.h \
	jamexp.h \
	jamsym.h \
	jamstack.h \
	jamheap.h \
	jamarray.h \
	jamjtag.h

jamnote.o : \
	jamnote.c \
	jamexprt.h \
	jamdefs.h \
	jamexec.h \
	jamutil.h

jamcrc.o : \
	jamcrc.c \
	jamexprt.h \
	jamdefs.h \
	jamexec.h \
	jamutil.h

jamsym.o : \
	jamsym.c \
	jamexprt.h \
	jamdefs.h \
	jamsym.h \
	jamheap.h \
	jamutil.h

jamstack.o : \
	jamstack.c \
	jamexprt.h \
	jamdefs.h \
	jamutil.h \
	jamsym.h \
	jamstack.h

jamheap.o : \
	jamheap.c \
	jamport.h \
	jamexprt.h \
	jamdefs.h \
	jamsym.h \
	jamstack.h \
	jamheap.h \
	jamutil.h

jamarray.o : \
	jamarray.c \
	jamexprt.h \
	jamdefs.h \
	jamexec.h \
	jamexp.h \
	jamsym.h \
	jamstack.h \
	jamheap.h \
	jamutil.h \
	jamcomp.h \
	jamarray.h

jamcomp.o : \
	jamcomp.c \
	jamdefs.h \
	jamcomp.h

jamjtag.o : \
	jamjtag.c \
	jamexprt.h \
	jamdefs.h \
	jamsym.h \
	jamutil.h \
	jamjtag.h

jamutil.o : \
	jamutil.c \
	jamutil.h

jamexp.o : \
	jamexp.c \
	jamexprt.h \
	jamdefs.h \
	jamexp.h \
	jamsym.h \
	jamheap.h \
	jamarray.h \
	jamutil.h \
	jamytab.h
