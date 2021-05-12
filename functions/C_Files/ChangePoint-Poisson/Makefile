# Makefile for changepoint © Haw Yang 2020
#
# Haw Yang
# Princeton University
# 
# 20200816: (HY) prepare for v2.0 publich release

PROGRAM = changepoint.exe
SOURCES = AddCPNode.c AHCluster.c BICCluster.c CheckCP.c DeleteCPNode.c \
          EMCluster.c FindCP.c MakeCPArray.c MergeCP.c SaveCP.c util.c main.c \
          changepoint.h critical_values.h
OBJECTS = AddCPNode.o AHCluster.o BICCluster.o CheckCP.o DeleteCPNode.o \
	  EMCluster.o FindCP.o MakeCPArray.o MergeCP.o SaveCP.o util.o main.o
GSLLIB = -lm -lgsl -lgslcblas 
LIB = -lm
CFLAGS = -O3
CC = gcc
OSTYPE := $(shell echo $$OSTYPE)
ifeq ($(strip $(OSTYPE)),msys)
  ########## MinGW - msys ##########
  # For Windows, make sure to include the libgsl.dll path in the system PATH
  # variable. This can be done by right-clicking 'My Computer' under
  # 'Properties.'
  # Revision:
  #   20120512: (HY) for MinGW32 4.6.2 that comes with Code::Blocks Win7 version
  #                  Note, it is only tested for MinGW32          
  PLATFORM = MinGW
  INCDIRFLAG = -I/c/MinGW/msys/1.0/local/include
  LIBDIRFLAG = -L/c/MinGW/msys/1.0/local/lib
endif
ifeq ($(strip $(OSTYPE)),darwin9.0)
  ########## Mac OS X 10.5 - Darwin 9.0 ##########
  # The directives assume the use of gsl installation using mac port.
  PLATFORM = Darwin
  INCDIRFLAG = -I/opt/local/include
  LIBDIRFLAG = -L/opt/local/lib
  # hard-coded static lib location
  STATICLIB = /opt/local/lib/libgslcblas.a /opt/local/lib/libgsl.a
endif
ifeq ($(strip $(OSTYPE)),darwin11)
  ########## Mac OS X 10.7 - Darwin 11 ##########
  # The directives assume the use of gsl installation using mac port.
  PLATFORM = Darwin
  INCDIRFLAG = -I/opt/local/include
  LIBDIRFLAG = -L/opt/local/lib
  # hard-coded static lib location
  STATICLIB = /opt/local/lib/libgslcblas.a /opt/local/lib/libgsl.a
endif
ifeq ($(strip $(OSTYPE)),darwin16)
  ########## Mac OS X 10.12 - Darwin 16 ##########
  # The directives assume the use of gsl installation using mac port.
  PLATFORM = Darwin
  INCDIRFLAG = -I/opt/local/include
  LIBDIRFLAG = -L/opt/local/lib
  # hard-coded static lib location
  STATICLIB = /opt/local/lib/libgslcblas.a /opt/local/lib/libgsl.a
endif
ifeq ($(strip $(OSTYPE)),darwin17)
  ########## Mac OS X 10.13 - Darwin 17 ##########
  # The directives assume the use of gsl installation using mac port.
  PLATFORM = Darwin
  INCDIRFLAG = -I/opt/local/include
  LIBDIRFLAG = -L/opt/local/lib
  # hard-coded static lib location
  STATICLIB = /opt/local/lib/libgslcblas.a /opt/local/lib/libgsl.a
endif
ifeq ($(strip $(OSTYPE)),darwin19)
  ########## Mac OS X 10.15 - Darwin 19 ##########
  # The directives assume the use of gsl installation using mac port.
  PLATFORM = Darwin
  INCDIRFLAG = -I/opt/local/include
  LIBDIRFLAG = -L/opt/local/lib
  # hard-coded static lib location
  STATICLIB = /opt/local/lib/libgslcblas.a /opt/local/lib/libgsl.a
endif
ifeq ($(strip $(OSTYPE)),linux-gnu)
  ########## Linux - linux-gnu ##########
  PLATFORM = Linux
  INCDIRFLAG = -I/usr/local/include
  LIBDIRFLAG = -L/usr/local/lib
  # hard-coded static lib location
  STATICLIB = /usr/local/lib/libgslcblas.a /usr/local/lib/libgsl.a
endif

$(PROGRAM): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(PROGRAM) $(GSLLIB) $(LIBDIRFLAG) 

.c.o:   ; $(CC) $(CFLAGS) -c $*.c $(INCDIRFLAG)

static:
	$(CC) $(CFLAGS) $(OBJECTS) $(STATICLIB) -o $(PROGRAM) $(LIB) $(LIBDIRFLAG) 

clean:
	rm -f $(PROGRAM) $(OBJECTS)
