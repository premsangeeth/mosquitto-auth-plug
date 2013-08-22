# Choose a back-end. Allowed values are
#	mysql
#	cdb

BACKEND=mysql
BE_CFLAGS=`mysql_config --cflags` -DBE_MYSQL=1
BE_LDFLAGS=`mysql_config --libs`
BE_DEPS=

#BACKEND=cdb
#CDBDIR=contrib/tinycdb-0.78
#CDB=$(CDBDIR)/cdb
#CDBINC=$(CDBDIR)/
#CDBLIB=$(CDBDIR)/libcdb.a
#BE_CFLAGS=-I$(CDBINC)/ -DBE_CDB=1
#BE_LDFLAGS=-L$(CDBDIR) -lcdb
#BE_DEPS=$(CDBLIB)

#MOSQUITTOSRC=../../../../pubgit/MQTT/mosquitto/src
#OPENSSLDIR=/usr/local/stow/openssl-1.0.0c/
#OSSLINC=-I$(OPENSSLDIR)/include
#OSSLIBS=-L$(OPENSSLDIR)/lib -lcrypto 
OSSLIBS=-lcrypto

MOSQ=/home/jpm/src/mosquitto-1.2/

CFLAGS=-fPIC -Wall -Werror -DBACKEND=$(BACKEND) $(BE_CFLAGS) -I$(MOSQ)/src -DDEBUG=1
LDFLAGS=$(BE_LDFLAGS) -L$(MOSQ)/lib/ -lmosquitto

OBJS=auth-plug.o base64.o pbkdf2-check.o be-$(BACKEND).o

all: auth-plug.so np 

auth-plug.so : $(OBJS) $(BE_DEPS)
	$(CC) -fPIC -shared $(OBJS) -o $@  $(OSSLIBS) $(BE_DEPS) $(LDFLAGS)

redis.o: redis.c redis.h Makefile
be-sqlite.o: be-sqlite.c be-sqlite.h Makefile
auth-plug.o: auth-plug.c be-$(BACKEND).h Makefile
be-cdb.o: be-cdb.c be-cdb.h Makefile
be-mysql.o: be-mysql.c be-mysql.h Makefile
pbkdf2-check.o: pbkdf2-check.c base64.h Makefile
base64.o: base64.c base64.h Makefile

np: np.c base64.o
	$(CC) $(CFLAGS) $^ -o $@ $(OSSLIBS)

$(CDBLIB):
	(cd $(CDBDIR); make libcdb.a cdb )

pwdb.cdb: pwdb.in
	$(CDB) -c -m  pwdb.cdb pwdb.in
clean :
	rm -f *.o *.so 
	(cd contrib/tinycdb-0.78; make realclean )
