def: def.sh
	./def.sh > def
	chmod +x def

quo: quo.sh
	./quo.sh > quo
	chmod +x quo

quit: quit.sh
	./quit.sh > quit
	chmod +x quit

echo: echo.sh
	./echo.sh > echo
	chmod +x echo

elfh: elfh.sh
	./elfh.sh > elfh
	chmod +x elfh

loop: loop.s
	arm-linux-gnueabi-gcc -o loop loop.s -static -nostdlib

clean:
	rm loop.o loop elfh echo quit quo def
