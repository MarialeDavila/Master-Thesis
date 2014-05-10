# remove without fussing about it
RM = /bin/rm -f

# compiler name and flags
CCC = g++
CCFLAGS = -O3 -fomit-frame-pointer -funroll-loops -fforce-addr -fexpensive-optimizations -Wno-deprecated

# loader flags
LDFLAGS = 

### local program information
EXEC=ganc
SOURCES= ganc.cpp

### intermediate objects
OBJECTS = $(SOURCES: .cpp=.o)

### includes
INCLUDES = 

### headers
HEADERS = maxheap.h vektor.h

### targets, dependencies and actions
$(EXEC): $(OBJECTS) Makefile
	$(LINK.cpp) $(CCFLAGS) -o $(EXEC) $(OBJECTS)

### sort out dependencies
depend:
	makedepend $(INCLUDES) $(HEADERS) $(SOURCES)

### housekeeping

clean:
	$(RM) *.o *~

cleanall: clean
	$(RM) $(EXEC)
