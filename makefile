SHELL = cmd
#OSATOOL = sage-js
#OSAARGS = res:osi:asm:sassemble
LSSTOOL = tools\lssc\lssc.exe
LSSARGS = Compile -y -r
RELEASETOOL = python tools\releasetool.py
NATIVE_SOURCES = $(wildcard ./native/*.*) $(wildcard ./native/*/*.*)
NATIVE_OUTPUTS = $(patsubst ./native/%,./build/%, $(NATIVE_SOURCES))
LSS_SOURCES = $(wildcard ./script/*.lss) $(wildcard ./script/*/*.lss) $(wildcard ./script/*/*/*.lss) $(wildcard ./script/*/*/*/*.lss) $(wildcard ./script/*/*/*/*/*.lss) $(wildcard ./script/*/*/*/*/*/*.lss) $(wildcard ./script/*/*/*/*/*/*/*.lss) $(wildcard ./script/*/*/*/*/*/*/*/*.lss) $(wildcard ./script/*/*/*/*/*/*/*/*/*.lss) $(wildcard ./script/*/*/*/*/*/*/*/*/*/*.lss) $(wildcard ./script/*/*/*/*/*/*/*/*/*/*/*.lss)
OSI_OUTPUT = ./build/data/Base.osi

default: build

build: native script data

clean:
	@if exist build\NUL rmdir build /s /q
	@if exist packaged\NUL rmdir packaged /s /q

run: build
	@start build\LEGOBionicle.exe

rebuild:
	@$(MAKE) -s clean
	@$(MAKE) -s build

.PHONY: extract diff release

# 
# Utility recipe for building releases (self-extracting 7z)
# 
release: ./packaged/Patch.exe

diff: build
	$(RELEASETOOL) package build\ "vanilla snapshot.txt" packaged\patch\

./packaged/Patch.exe: diff
	@if exist packaged\Patch.exe rmdir packaged\Patch.exe
	@cd packaged\patch\ && ..\..\tools\7zip\7za.exe a -sfx7z.sfx ..\Patch.exe *
# 
# Native files copied from native/
# 
native: $(NATIVE_OUTPUTS)

./build/%: ./native/%
	@echo Copying '$@'...
	@if not exist $(subst /,\,$(dir $@))NUL mkdir $(subst /,\,$(dir $@))
	@copy /B $(subst /,\,$<) $(strip $(subst /,\,$@)) > NUL

# 
# Script files are compiled from script/ with sage-js
# 
script: $(OSI_OUTPUT)

$(OSI_OUTPUT): $(LSS_SOURCES)
	@echo Compiling '$@'...
	@if not exist $(subst /,\,$(dir $@))NUL mkdir $(subst /,\,$(dir $@))
	$(LSSTOOL) $(LSSARGS) ./script -o $(subst /,\,$@)
#	@$(OSATOOL) $(OSAARGS) $(subst /,\,$@) ./script/

# 
# Data files are copied from data/
# 
DATA_SOURCES = $(wildcard ./data/*.*) $(wildcard ./data/*/*.*) $(wildcard ./data/*/*/*.*) $(wildcard ./data/*/*/*/*.*) $(wildcard ./data/*/*/*/*/*.*) $(wildcard ./data/*/*/*/*/*/*.*)
DATA_OUTPUTS = $(patsubst ./data/%,./build/data/%,$(DATA_SOURCES))
data: $(DATA_OUTPUTS)

./build/data/%: ./data/%
	@echo Copying '$@'...
	@if not exist $(subst /,\,$(dir $@))NUL mkdir $(subst /,\,$(dir $@))
	@copy /B $(subst /,\,$<) $(strip $(subst /,\,$@)) > NUL