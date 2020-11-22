TARGET=all

SCALA_SOURCES=$(shell find . -name "*.scala")

.PHONY: build
build: build/MemorySubsystem.v
build/MemorySubsystem.v: $(SCALA_SOURCES)
	mkdir -p build
	sbt --supershell=never "runMain main.GenerateMemorySubsystem"

.PHONY: test
test:
	sbt --supershell=never "test:runMain main.Main $(TARGET)"

clean:
	-rm -r test_run_dir
	-rm -r build
	-rm -r test_build

