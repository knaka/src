all:
	ln -sf cc cpp

clean:
	rm -f *~
	for i in *; \
	do \
	  if [ -d $$i -a -e $$i/Makefile ]; \
	  then \
	    make -C $$i clean; \
	  fi \
	done

# comment
