APP=jigplate
BIN=dist/build/$(APP)/$(APP)

all : $(BIN)

dist/setup-config : $(APP).cabal
	runhaskell Setup.hs configure

$(BIN) : dist/setup-config $(APP).hs
	runhaskell Setup.hs build
	@touch $@ # cabal doesn't always update the build (if it doesn't need to)

.PHONY : clean
clean :
	-rm -rf dist
