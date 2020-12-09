default:
	@echo pick your target
	@echo install
	@echo test

install:
	@cp stock-stats stock-stats-nocache ${HOME}/bin/.
	@[ ! -e ${HOME}/bin/assert.sh ] && ( mkdir -p ${HOME}/bash; cd ${HOME/bash}; git clone git@github.com:torokmark/assert.sh.git; cp assert.sh/assert.sh ${HOME}/bin ) || :
	@type brew >/dev/null 2>&1 || { echo you want to install brew; exit 1; }
	@type jq   >/dev/null 2>&1 || brew install jq
	@npm install mississippi
test:
	./test.sh
