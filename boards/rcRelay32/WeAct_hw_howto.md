# WeAct STM32G031 Hardware Guide for rcRelay32

## Hardware Overview

**Board:** WeAct STM32G031F6P6 Development Board  
**MCU:** STM32G031F6P6 (20-pin, 32KB Flash, 8KB RAM)  
**Clock:** 64MHz (HSI internal oscillator)

## Pin Assignments

### UART1 - Relay/Passthrough Output
- **TX:** PA11 (remapped to USART1_TX)
- **RX:** PA12 (remapped to USART1_RX)
- **Baudrate:** 400,000 baud (8N1)
- **Function:** Relays/rewrites CRSF packets to flight controller or downstream device
- **Note:** STM32G031F6P6 (20-pin) doesn't have PA9/PA10, so PA11/PA12 are remapped via SYSCFG

### UART2 - CRSF Input
- **TX:** PA2
- **RX:** PA3
- **Baudrate:** 420,000 baud (8N1)
- **Function:** Receives CRSF from radio receiver

### LED Indicator
- **Pin:** PA4 (inverted logic - active LOW)
- **Patterns:**
  - **Steady ON:** Initializing
  - **Fast 1-flash** (~3/sec): No CRSF input detected (UnConnected state)
  - **Slow 2-flash** (100ms on, 100ms off, 100ms on, 5000ms pause): CRSF connected and relaying (Run state)

## Firmware Upload

### From Linux devcontainer to Windows PC

1. **Download firmware from devcontainer:**
   - Right-click `relay_01.bin` in VS Code file explorer
   - Select "Download..." to save to Windows PC

2. **Flash to STM32:**
   - Put STM32G031 into DFU mode (connect BOOT0 to 3.3V, press reset)
   - Flash address: `0x08000000`
   
   **Using dfu-util:**
   ```bash
   dfu-util -a 0 -s 0x08000000:leave -D relay_01.bin
   ```
   
   **Using STM32CubeProgrammer CLI:**
   ```bash
   STM32_Programmer_CLI -c port=usb1 -w relay_01.bin 0x08000000 -v -s
   ```

### Build Commands

```bash
cd /workspaces/wmucpp/boards/rcRelay32
make -f Makefile.G031 clean
make -f Makefile.G031 g031
```

Binary output: `relay_01.bin` (~13KB)

### Enable WeAct Board in Source

Edit `relay_01.cc` line 19:

```cpp
#define USE_WEACT // STM32G031
```

Comment out other board definitions.

## CRSF Parameter Settings

Access via LUA script or CRSF configurator on your transmitter:

### Half-Duplex Mode
- **Options:** Off (default) | On
- **Function:** Single-wire communication on UART1
- **When to use:** Connecting to single-wire telemetry devices (e.g., FrSky SmartPort)
- **Pin used:** PA11 (bidirectional when enabled)
- **Default:** Keep **Off** for standard two-wire UART operation

### Other Available Settings
- Failsafe mode
- Telemetry forwarding options
- Link statistics configuration
- IrDA mode (if enabled in build)

## Debugging Without Serial Console

Both UARTs are occupied by the CRSF application, so debug output is not available. Use the **LED on PA4** to diagnose firmware state:

- If LED stays **steady ON** for more than 2 seconds → stuck in initialization
- If LED shows **fast 1-flash** → firmware running, waiting for CRSF input from receiver
- If LED shows **slow 2-flash** → CRSF connected, relay active

## Connection Diagram

```
Radio Receiver (CRSF) ──→ UART2 (PA2/PA3) ──→ [STM32G031] ──→ UART1 (PA11/PA12) ──→ Flight Controller
                        420k baud                                 400k baud
```

## Notes

- **Pin Remapping:** The STM32G031F6P6 (20-pin package) doesn't have PA9/PA10 pins
- **Physical pins PA11/PA12** are remapped via SYSCFG to function as USART1_TX/USART1_RX
- This remapping is automatically handled in firmware initialization
- Half-duplex mode uses only the TX pin (PA11) for bidirectional communication when enabled
- Default configuration uses full-duplex (separate TX/RX wires)
- Flash size is only 32KB, so firmware must remain compact

## Hardware Considerations

- **Limited Flash:** Only 32KB available - keep firmware minimal
- **Pin Spacing:** WeAct board has standard 2.54mm headers for easy prototyping
- **Power:** Can be powered via USB or external 3.3V/5V on VCC pin
- **Boot Mode:** BOOT0 button available for easy DFU mode entry
