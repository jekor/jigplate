BIN=jigplate

all : $(BIN)

dist/setup-config : $(BIN).cabal
	cabal configure

$(BIN) : dist/build/$(BIN)/$(BIN)
	cp $< .

dist/build/$(BIN)/$(BIN) : dist/setup-config $(BIN).hs
	cabal build
	@touch $@ # cabal doesn't always update the build (if it doesn't need to)
