CFLAGS += -std=c99 -Wall

SRCDIR = $(CURDIR)
TESTDIR ?= /tmp/path-mapping
TESTTOOLS = testtool-execl testtool-printenv
UNIT_TESTS = test-pathmatching

all: path-mapping.so testtools unit_tests

path-mapping.so: path-mapping.c override-macros.h
	gcc $(CFLAGS) -shared -fPIC path-mapping.c -o path-mapping.so -ldl

clean:
	rm -f *.so
	rm -rf $(TESTDIR)

test: unit_tests
	for f in $(UNIT_TESTS); do $(TESTDIR)/$$f; done
	test/integration-tests.sh

unit_tests: $(addprefix $(TESTDIR)/, $(UNIT_TESTS))

testtools: $(addprefix $(TESTDIR)/, $(TESTTOOLS))

$(TESTDIR)/test-%: $(SRCDIR)/test/test-%.c $(SRCDIR)/path-mapping.c $(SRCDIR)/override-macros.h
	mkdir -p $(TESTDIR)
	cd $(TESTDIR); gcc $(CFLAGS) $< "$(SRCDIR)/path-mapping.c" -ldl -o $@

$(TESTDIR)/testtool-%: $(SRCDIR)/test/testtool-%.c
	mkdir -p $(TESTDIR)
	cd $(TESTDIR); gcc $(CFLAGS) $^ -o $@

.PHONY: all clean test unit_tests testtools