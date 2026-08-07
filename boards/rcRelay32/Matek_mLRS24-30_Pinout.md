# Matek mLRS24-30 Board Pinout

**Board:** Matek mLRS24-30  
**MCU:** STM32G431KB  
**RF Module:** SX1280 (2.4 GHz)  
**Power Amplifier:** SKY65383-11 (max 30 dBm / 1W)

---

## Pin Header Connections

All the following pins are broken out on pin headers:

| Label | Pin    | Primary Function | Alternative Functions                        |
|-------|--------|------------------|----------------------------------------------|
| Tx1   | PA9    | UART1_TX         | I2C2_SCL / TIM1_CH2 / TIM2_CH3              |
| Rx1   | PA10   | UART1_RX         | TIM1_CH3 / TIM2_CH4                          |
| Tx2   | PB3    | UART2_TX         | TIM2_CH2                                     |
| Rx2   | PB4    | UART2_RX         | TIM3_CH1 / TIM16_CH1                         |
| LT1   | PA2    | LPUART1_TX       | UART2_TX / TIM2_CH3 / TIM15_CH1 / ADC1_IN3   |
| LR1   | PA3    | LPUART1_RX       | UART2_RX / TIM2_CH4 / TIM15_CH2 / ADC1_IN4   |

---

## Solder Pad Connections

| Label | Pin    | Function         | Alternative Functions                        |
|-------|--------|------------------|----------------------------------------------|
| FAN   | PA8    | GPIO             | I2C2_SDA / TIM1_CH1                          |
| D-    | PA11   | USB DM           | TIM1_CH4 / TIM4_CH1 / FDCAN1_RX              |
| D+    | PA12   | USB DP           | TIM4_CH2 / TIM16_CH1 / FDCAN1_TX             |
| SWD   | PA13   | SWDIO            | I2C1_SCL / TIM4_CH3                          |
| SWC   | PA14   | SWDCLK           | I2C1_SDA / TIM8_CH2                          |

---

## SX1280 LoRa Module (SPI1)

| Function  | Pin    | Notes                                        |
|-----------|--------|----------------------------------------------|
| SPI_SCK   | PA5    | SPI1_SCK                                     |
| SPI_MISO  | PA6    | SPI1_MISO                                    |
| SPI_MOSI  | PA7    | SPI1_MOSI                                    |
| SPI_CS    | PA4    | Chip Select                                  |
| RESET     | PB6    | SX1280 Reset                                 |
| DIO       | PA15   | SX1280 Digital I/O (EXTI15_10)               |
| BUSY      | PB5    | SX1280 Busy                                  |
| RX_EN     | PB0    | RF Switch RX Enable                          |
| TX_EN     | PB7    | RF Switch TX Enable                          |

**SPI Configuration:**
- Clock Speed: 9 MHz
- Clock Polarity: CPOL = 0, CPHA = 0 (1EDGE mode)
- Regulator Mode: DC-DC

---

## LEDs & Button

| Component  | Pin    | Notes                                        |
|------------|--------|----------------------------------------------|
| LED_GREEN  | PA1    | Active High                                  |
| LED_RED    | PA0    | Active High                                  |
| BUTTON     | PB8    | Input with Pull-up                           |

---

## Receiver Configuration (RX)

### UART Assignments:
- **UARTB (Serial Port):** UART1 on PA9/PA10
  - Baud: Configurable (RX_SERIAL_BAUDRATE)
  - TX Buffer: 1024 bytes
  - RX Buffer: 1024 bytes

- **UART (Output Port):** UART2 on PB3/PB4
  - Default Baud: 100000 (SBus)
  - TX Buffer: 256 bytes
  - Supports normal and inverted output

- **UARTF (Debug Port):** LPUART1 on PA2/PA3
  - Baud: 115200
  - TX Buffer: 512 bytes

---

## Transmitter Configuration (TX)

### UART Assignments:
- **UARTB (Serial Port):** LPUART1 on PA2/PA3
  - Baud: Configurable (TX_SERIAL_BAUDRATE)
  - TX/RX Buffers: Configurable

- **UARTD (Serial2/Wireless Bridge):** UART1 on PA9/PA10
  - Baud: 115200
  - For HC-04 module or wireless bridge
  - TX/RX Buffers: Configurable

- **UART (JR Pin5/MBridge):** UART2 on PB3/PB4
  - Baud: 400000
  - TX Buffer: 512 bytes
  - RX Buffer: 512 bytes
  - Full internal support (no external diode required)

- **UARTE (Input Port):** UART2 on PB3/PB4
  - Baud: 100000 (SBus default)
  - RX Buffer: 512 bytes
  - Supports normal and inverted input with TX/RX swap

### USB:
- **USB-C:** PA11 (D-), PA12 (D+)
  - Used as COM port for configuration

### I2C Display (Optional with mod):
- **I2C1:** PA13 (SCL), PA14 (SDA)
  - Speed: 400 kHz
  - DMA Mode enabled
  - For optional OLED display (180° rotation)

### 5-Way Switch (Optional with display mod):
- **ADC Input:** PA2 (ADC1_IN3)
  - Threshold values for BetaFPV 1W Micro scheme:
    - UP: 3230
    - DOWN: 0
    - LEFT: 1890
    - RIGHT: 2623
    - CENTER: 1205

---

## Power & Cooling

### Cooling Fan:
- **Pin:** PA8
- **Control:** GPIO (High = ON)
- **Auto-on:** Power ≥ 27 dBm (500 mW)
- **Temperature Sensor:** Internal MCU temperature sensor (ADC1)

### Power Levels:
| Setting  | SX1280 Power | Output Power | TX Current (est.) |
|----------|--------------|--------------|-------------------|
| 17 dBm   | 0-1          | ~50 mW       | Low               |
| 20 dBm   | 4            | ~100 mW      | Medium            |
| 24 dBm   | 8            | ~250 mW      | Medium-High       |
| 27 dBm   | 12           | ~500 mW      | High (Fan ON)     |
| 30 dBm   | 19           | ~1000 mW     | Max (Fan ON)      |

**Default Power:** 100 mW (20 dBm)

---

## CAN Bus Support

The board supports FDCAN1 on PA11/PA12 (same pins as USB, mutually exclusive):
- **FDCAN1_RX:** PA11
- **FDCAN1_TX:** PA12

---

## Timers

- **MICROS_TIM:** TIM3 (for microsecond timing)
- **CLOCK_TIM:** TIM2 (for receiver clock)
- **DWT:** Used for delay functions

---

## Memory

- **Flash Size:** 128 kB
- **EEPROM Emulation:** Starting at page 60 (2 kB pages)

---

## Notes

1. **Dual Boot Pads:** The board has solder pads for both RX and TX configurations
2. **TX/RX Pin Swapping:** Supported on UART2 for inverted protocols
3. **Pin Conflicts:**
   - USB (PA11/PA12) and FDCAN1 are mutually exclusive
   - I2C1 (PA13/PA14) conflicts with SWD debugging pins
   - UART2 (PB3/PB4) is used for different purposes in RX vs TX mode
4. **Optional Modifications:**
   - HC-04 Bluetooth module support on UART1
   - OLED display on I2C1 (requires SWD pin reallocation)
   - 5-way switch for display navigation

---

## Pin Function Summary by Port

### Port A:
- PA0: LED_RED
- PA1: LED_GREEN
- PA2: LPUART1_TX / ADC1_IN3 (5-way switch in TX mode with display)
- PA3: LPUART1_RX / ADC1_IN4
- PA4: SPI1_CS
- PA5: SPI1_SCK
- PA6: SPI1_MISO
- PA7: SPI1_MOSI
- PA8: FAN control
- PA9: UART1_TX
- PA10: UART1_RX
- PA11: USB_DM / FDCAN1_RX
- PA12: USB_DP / FDCAN1_TX
- PA13: SWDIO / I2C1_SCL (with display mod)
- PA14: SWDCLK / I2C1_SDA (with display mod)
- PA15: SX1280_DIO

### Port B:
- PB0: SX1280_RX_EN
- PB3: UART2_TX
- PB4: UART2_RX
- PB5: SX1280_BUSY
- PB6: SX1280_RESET
- PB7: SX1280_TX_EN
- PB8: BUTTON

---

*Extracted from mLRS firmware source code v1.x*  
*Repository: https://github.com/olliw42/mLRS*
