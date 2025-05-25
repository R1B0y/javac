BUILD_DIR := build

all: $(BUILD_DIR)/parser

$(BUILD_DIR)/parser: $(BUILD_DIR)/lex.yy.c $(BUILD_DIR)/parser.tab.c
	gcc -o $@ $^ -lfl

$(BUILD_DIR)/lex.yy.c: scanner.l | $(BUILD_DIR)
	flex -o $@ $<

$(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/parser.tab.h $(BUILD_DIR)/parser.output: parser.y | $(BUILD_DIR)
	bison -d -v -o $(BUILD_DIR)/parser.tab.c $<

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)

