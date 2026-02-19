# Matek mLRS Rx mR24-30 Hardware Guide for rcRelay32

## Hardware Overview

**Board:** Matek mLRS Rx mR24-30  
**MCU:** STM32G431KB (32-pin, 128KB Flash, 32KB RAM)  
**Clock:** 170MHz (HSI internal oscillator)

## Pin Assignments

### UART1 - Relay/Passthrough Output
- **TX:** PA9
- **RX:** PA10
- **Baudrate:** 921,000 baud (8N1)
- **Function:** Relays/rewrites CRSF packets to flight controller or downstream device

### UART2 - CRSF Input
- **TX:** PB3
- **RX:** PB4
- **Baudrate:** 420,000 baud (8N1)
- **Function:** Receives CRSF from radio receiver

### LED Indicator
- **Pin:** PA1 (green LED)
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
   - Put STM32G431 into DFU mode (BOOT0 high during reset)
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
make -f Makefile.Matek clean
make -f Makefile.Matek matek
```

Binary output: `relay_01.bin` (~17KB)

## CRSF Parameter Settings

Access via LUA script or CRSF configurator on your transmitter:

### Half-Duplex Mode
- **Options:** Off (default) | On
- **Function:** Single-wire communication on UART1
- **When to use:** Connecting to single-wire telemetry devices (e.g., FrSky SmartPort)
- **Pin used:** PA9 (bidirectional when enabled)
- **Default:** Keep **Off** for standard two-wire UART operation

### Other Available Settings
- Failsafe mode
- Telemetry forwarding options
- Link statistics configuration
- IrDA mode (if enabled in build)

## Debugging Without Serial Console

Both UARTs are occupied by the CRSF application, so debug output is not available. Use the **LED on PA1** to diagnose firmware state:

- If LED stays **steady ON** for more than 2 seconds → stuck in initialization
- If LED shows **fast 1-flash** → firmware running, waiting for CRSF input from receiver
- If LED shows **slow 2-flash** → CRSF connected, relay active

## Connection Diagram

```
Radio Receiver (CRSF) ──→ UART2 (PB3/PB4) ──→ [STM32G431] ──→ UART1 (PA9/PA10) ──→ Flight Controller
                        420k baud                                921k baud
```

## Notes

- The Matek mLRS Rx mR24-30 does not require PA11/PA12 remapping (that's only for STM32G0 boards with USB conflicts)
- Half-duplex mode uses only the TX pin (PA9) for bidirectional communication when enabled
- Default configuration uses full-duplex (separate TX/RX wires)
