
TOP=top
SIM=sim
PRJ=sources.prj
SRC=$(filter-out vhdl work,$(shell cat $(PRJ)))


.PHONY: help
help:
	@echo "view       Open waveform in graphical viewer"
	@echo "sim        Run the simulation script"
	@echo "isim       Start interactive graphical simulation"
	@echo "clean      Remove Webtalk and logs"
	@echo "cleanmore  Also remove elaborated project"
	@echo "cleanall   Also remove waveform database"


.PHONY: view
view:
	xsim --t wave.tcl $(SIM).wdb -gui

.PHONY: sim
sim: $(SIM).wdb

.PHONY: isim
isim:
	xsim --t wave.tcl $(SIM) --gui


$(SIM).wdb: sim.tcl xelab.pb
	xsim --t sim.tcl $(SIM) | sed '/^##.*$$/d'

xelab.pb: $(SRC)
	xelab -prj $(PRJ) -debug typical -s $(SIM) $(TOP)


.PHONY: clean
clean:
	rm -rf .Xil *.log *.jou

.PHONY: cleanmore
cleanmore: clean
	rm -rf xsim.dir *.pb .hbs

.PHONY: cleanall
cleanall: cleanmore
	rm -f *.wdb


.PHONY: genprj
genprj:
	find ../src -type f -name *.vhdl | sed 's/^/vhdl work /' > $(PRJ)
	echo >> $(PRJ)
