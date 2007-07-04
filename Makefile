BUILD=ghc --make hledger.hs -o hledger -prof -auto-all
BUILDOPT=ghc --make hledger.hs -o hledgeropt -O2
PROFILE=./hledger -s balance +RTS -p
TIME=`date +"%Y%m%d%H%M"`

build: Tags
	$(BUILD)

buildopt opt: clean
	$(BUILDOPT)

profile: build
	$(PROFILE)
	mv hledger.prof profs/$(TIME).prof
	rm -f last.prof
	ln -s profs/$(TIME).prof last.prof
	head -20 profs/$(TIME).prof >simple.prof
	cat simple.prof
	./simplifyprof.hs <last.prof >>simple.prof

xprofile: build
	$(PROFILE) -x
	mv hledger.prof profs/$(TIME).xprof
	ghcprof profs/$(TIME).xprof

#LEDGER=test.dat
compare: build
	rm -f 1 2
	ledger -s balance >1
	ledger register >>1
	ledger print >>1
	./hledger -s balance >2
	./hledger register >>2
	./hledger print >>2
	diff 1 2

haddock:
	haddock -h -o doc *.hs

overview:
	@./overview.hs Types.hs | tee OVERVIEW

loc:
	@darcs trackdown 'find . -name "*hs" |xargs wc -l |echo OUTPUT `tail -1`; false' |ruby -nae'puts $$F[1] if /^OUTPUT/'

Tags:
	hasktags *hs

clean:
	rm -f *.o *.hi *~ 1 2

Clean: clean
	rm -f hledger hledgeropt overview TAGS tags
