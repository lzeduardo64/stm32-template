include ./config.mk
include $(OPENCM3_DIR)/mk/gcc-config.mk
include $(OPENCM3_DIR)/mk/genlink-config.mk

# Arquivo de script de ligação gerado
LDSCRIPT = $(BUILDDIR)/generated.$(DEVICE).ld

# Includes
INCLUDES = -I$(OPENCM3_DIR)/include \
           -Iinclude

# Flags de compilação
CFLAGS = -mthumb -Os -ffunction-sections -fdata-sections \
         -DSTM32F1 -Wall $(INCLUDES)

# Flags de linkagem
LDFLAGS = -nostartfiles -T$(LDSCRIPT) -Wl,--gc-sections -Wl,-Map=$(BUILDDIR)/main.map

# Arquivos do projeto
SRCS = $(wildcard $(SRCDIR)/*.c) 
OBJS = $(patsubst %.c, $(BUILDDIR)/%.o, $(SRCS))

# Linkagem final
$(BUILDDIR)/main.elf: $(OBJS) $(LDSCRIPT)
	$(CC) $(OBJS) -L$(OPENCM3_DIR)/lib -lopencm3_stm32f1 $(LDFLAGS) -o $@
	$(SIZE) $@

# Alvo principal
all: $(BUILDDIR)/main.elf

# Criação da pasta build
$(BUILDDIR):
	@ mkdir -p $(BUILDDIR)

# Compilação dos arquivos do projeto
$(BUILDDIR)/%.o: %.c | $(BUILDDIR)
	@ mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Gerar arquivo binário para flash
$(BUILDDIR)/main.bin: $(BUILDDIR)/main.elf
	$(OBJCOPY) -O binary $< $@

# Flash via st-flash
flash: $(BUILDDIR)/main.bin
	st-flash write $(BUILDDIR)/main.bin 0x08000000

# Limpar build
clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean flash

# Incluir regras da libopencm3 para gerar o ldscript
include $(OPENCM3_DIR)/mk/genlink-rules.mk
