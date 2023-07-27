.PHONY: clean release
CLEAN_COV=if [ -e luacov.report.out ]; then rm luacov.report.out; fi; if [ -e luacov.stats.out ]; then rm luacov.stats.out; fi
PWD=$(shell pwd)

LUA_PATH := ./src/?.lua
LUA_PATH := $(LUA_PATH);$(PWD)/external/du-stream/src/?.lua
LUA_PATH := $(LUA_PATH);$(PWD)/external/du-stream/external/du-serializer/?.lua


all: release

lua_path:
	@echo "$(LUA_PATH)"

clean:
	@rm -rf out

test:

release: clean
	@LUA_PATH="$(LUA_PATH)" du-lua build --copy=release/GateControl

release-ci: clean
	@LUA_PATH="$(LUA_PATH)" du-lua build

