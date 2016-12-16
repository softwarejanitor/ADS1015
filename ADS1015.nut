/**************************************************************************/
/*!
    @file     ADS1015.nut
    @author   K. Townsend (Adafruit Industries)
    @license  BSD (see license.txt)
    This is a library for the Adafruit ADS1015 breakout board
    ----> https://www.adafruit.com/products/???
    Adafruit invests time and resources providing this open source code,
    please support Adafruit and open-source hardware by purchasing
    products from Adafruit!
    @section  HISTORY
    v1.0  - First release
    v1.1  - Added ADS1115 support - W. Earl

    Ported from Arduino to Esquilo 20161216 Leeland Heins
*/
/**************************************************************************/

/*=========================================================================
    CONVERSION DELAY (in mS)
    -----------------------------------------------------------------------*/
const ADS1015_CONVERSIONDELAY         = 1;
const ADS1115_CONVERSIONDELAY         = 8;
/*=========================================================================*/

/*=========================================================================
    POINTER REGISTER
    -----------------------------------------------------------------------*/
const ADS1015_REG_POINTER_MASK        = 0x03;
const ADS1015_REG_POINTER_CONVERT     = 0x00;
const ADS1015_REG_POINTER_CONFIG      = 0x01;
const ADS1015_REG_POINTER_LOWTHRESH   = 0x02;
const ADS1015_REG_POINTER_HITHRESH    = 0x03;
/*=========================================================================*/

/*=========================================================================
    CONFIG REGISTER
    -----------------------------------------------------------------------*/
const ADS1015_REG_CONFIG_OS_MASK      = 0x8000;
const ADS1015_REG_CONFIG_OS_SINGLE    = 0x8000;  // Write: Set to start a single-conversion
const ADS1015_REG_CONFIG_OS_BUSY      = 0x0000;  // Read: Bit = 0 when conversion is in progress
const ADS1015_REG_CONFIG_OS_NOTBUSY   = 0x8000;  // Read: Bit = 1 when device is not performing a conversion

const ADS1015_REG_CONFIG_MUX_MASK     = 0x7000;
const ADS1015_REG_CONFIG_MUX_DIFF_0_1 = 0x0000;  // Differential P = AIN0, N = AIN1 (default)
const ADS1015_REG_CONFIG_MUX_DIFF_0_3 = 0x1000;  // Differential P = AIN0, N = AIN3
const ADS1015_REG_CONFIG_MUX_DIFF_1_3 = 0x2000;  // Differential P = AIN1, N = AIN3
const ADS1015_REG_CONFIG_MUX_DIFF_2_3 = 0x3000;  // Differential P = AIN2, N = AIN3
const ADS1015_REG_CONFIG_MUX_SINGLE_0 = 0x4000;  // Single-ended AIN0
const ADS1015_REG_CONFIG_MUX_SINGLE_1 = 0x5000;  // Single-ended AIN1
const ADS1015_REG_CONFIG_MUX_SINGLE_2 = 0x6000;  // Single-ended AIN2
const ADS1015_REG_CONFIG_MUX_SINGLE_3 = 0x7000;  // Single-ended AIN3
const ADS1015_REG_CONFIG_PGA_MASK     = 0x0E00;
const ADS1015_REG_CONFIG_PGA_6_144V   = 0x0000;  // +/-6.144V range = Gain 2/3
const ADS1015_REG_CONFIG_PGA_4_096V   = 0x0200;  // +/-4.096V range = Gain 1
const ADS1015_REG_CONFIG_PGA_2_048V   = 0x0400;  // +/-2.048V range = Gain 2 (default)
const ADS1015_REG_CONFIG_PGA_1_024V   = 0x0600;  // +/-1.024V range = Gain 4
const ADS1015_REG_CONFIG_PGA_0_512V   = 0x0800;  // +/-0.512V range = Gain 8
const ADS1015_REG_CONFIG_PGA_0_256V   = 0x0A00;  // +/-0.256V range = Gain 16

const ADS1015_REG_CONFIG_MODE_MASK    = 0x0100;
const ADS1015_REG_CONFIG_MODE_CONTIN  = 0x0000;  // Continuous conversion mode
const ADS1015_REG_CONFIG_MODE_SINGLE  = 0x0100;  // Power-down single-shot mode (default)

const ADS1015_REG_CONFIG_DR_MASK      = 0x00E0;
const ADS1015_REG_CONFIG_DR_128SPS    = 0x0000;  // 128 samples per second
const ADS1015_REG_CONFIG_DR_250SPS    = 0x0020;  // 250 samples per second
const ADS1015_REG_CONFIG_DR_490SPS    = 0x0040;  // 490 samples per second
const ADS1015_REG_CONFIG_DR_920SPS    = 0x0060;  // 920 samples per second
const ADS1015_REG_CONFIG_DR_1600SPS   = 0x0080;  // 1600 samples per second (default)
const ADS1015_REG_CONFIG_DR_2400SPS   = 0x00A0;  // 2400 samples per second
const ADS1015_REG_CONFIG_DR_3300SPS   = 0x00C0;  // 3300 samples per second

const ADS1015_REG_CONFIG_CMODE_MASK   = 0x0010;
const ADS1015_REG_CONFIG_CMODE_TRAD   = 0x0000;  // Traditional comparator with hysteresis (default)
const ADS1015_REG_CONFIG_CMODE_WINDOW = 0x0010;  // Window comparator

const ADS1015_REG_CONFIG_CPOL_MASK    = 0x0008;
const ADS1015_REG_CONFIG_CPOL_ACTVLOW = 0x0000;  // ALERT/RDY pin is low when active (default)
const ADS1015_REG_CONFIG_CPOL_ACTVHI  = 0x0008;  // ALERT/RDY pin is high when active

const ADS1015_REG_CONFIG_CLAT_MASK    = 0x0004;  // Determines if ALERT/RDY pin latches once asserted
const ADS1015_REG_CONFIG_CLAT_NONLAT  = 0x0000;  // Non-latching comparator (default)
const ADS1015_REG_CONFIG_CLAT_LATCH   = 0x0004;  // Latching comparator

const ADS1015_REG_CONFIG_CQUE_MASK    = 0x0003;
const ADS1015_REG_CONFIG_CQUE_1CONV   = 0x0000;  // Assert ALERT/RDY after one conversions
const ADS1015_REG_CONFIG_CQUE_2CONV   = 0x0001;  // Assert ALERT/RDY after two conversions
const ADS1015_REG_CONFIG_CQUE_4CONV   = 0x0002;  // Assert ALERT/RDY after four conversions
const ADS1015_REG_CONFIG_CQUE_NONE    = 0x0003;  // Disable the comparator and put ALERT/RDY in high state (default)
/*=========================================================================*/

enum adsGain_t;
{
    GAIN_TWOTHIRDS    = ADS1015_REG_CONFIG_PGA_6_144V,
    GAIN_ONE          = ADS1015_REG_CONFIG_PGA_4_096V,
    GAIN_TWO          = ADS1015_REG_CONFIG_PGA_2_048V,
    GAIN_FOUR         = ADS1015_REG_CONFIG_PGA_1_024V,
    GAIN_EIGHT        = ADS1015_REG_CONFIG_PGA_0_512V,
    GAIN_SIXTEEN      = ADS1015_REG_CONFIG_PGA_0_256V
};

class _ADS1015
{
    i2c = null;
    addr = 0;
    v = 0;

    m_conversionDelay = 0;
    m_bitShift = 0;
    m_gain = 0;

    constructor (_i2c, _addr, _v)
    {
        i2c = _i2c;
        addr = _addr;

        if (_v = 1015) {
            m_conversionDelay = ADS1015_CONVERSIONDELAY;
            m_bitShift = 4;
            m_gain = GAIN_TWOTHIRDS;  /* +/- 6.144V range (limited to VDD +0.3V max!) */
        } else {
            m_conversionDelay = ADS1115_CONVERSIONDELAY;
            m_bitShift = 0;
            m_gain = GAIN_TWOTHIRDS;  /* +/- 6.144V range (limited to VDD +0.3V max!) */
        }
    }
};

/**************************************************************************/
/*!
    @brief  Writes 16-bits to the specified destination register
*/
/**************************************************************************/
function writeRegister(i2cAddress, reg, value)
{
    local writeBlob = blob(3);

    writeBlob[0] = reg;
    writeBlob[1] = value >> 8;
    writeBlob[2] = value & 0xFF;

    i2c.address(addr);
    i2c.write(writeBlob);
}

/**************************************************************************/
/*!
    @brief  Writes 16-bits to the specified destination register
*/
/**************************************************************************/
function readRegister(i2cAddress, reg)
{
    local writeBlob(1)
    local readBlob(2);

    writeBlob[0] = ADS1015_REG_POINTER_CONVERT;
    readBlob[0] = 0;
    readBlob[1] = 0;

    i2c.address(addr);
    i2c.xfer(writeBlob, readBlob);

    return (readBlob[0] << 8) | readBlob[1];
}

/**************************************************************************/
/*!
    @brief  Sets the gain and input voltage range
*/
/**************************************************************************/
function ADS1015::setGain(gain)
{
  m_gain = gain;
}

/**************************************************************************/
/*!
    @brief  Gets a gain and input voltage range
*/
/**************************************************************************/
function ADS1015::getGain()
{
  return m_gain;
}

/**************************************************************************/
/*!
    @brief  Gets a single-ended ADC reading from the specified channel
*/
/**************************************************************************/
function ADS1015::readADC_SingleEnded(channel)
{
    if (channel > 3) {
        return 0;
    }

    // Start with default values
    config = ADS1015_REG_CONFIG_CQUE_NONE    |  // Disable the comparator (default val)
             ADS1015_REG_CONFIG_CLAT_NONLAT  |  // Non-latching (default val)
             ADS1015_REG_CONFIG_CPOL_ACTVLOW |  // Alert/Rdy active low   (default val)
             ADS1015_REG_CONFIG_CMODE_TRAD   |  // Traditional comparator (default val)
             ADS1015_REG_CONFIG_DR_1600SPS   |  // 1600 samples per second (default)
             ADS1015_REG_CONFIG_MODE_SINGLE;    // Single-shot mode (default)

    // Set PGA/voltage range
    config |= m_gain;

    // Set single-ended input channel
    switch (channel) {
        case 0 :
            config |= ADS1015_REG_CONFIG_MUX_SINGLE_0;
            break;
        case 1 :
            config |= ADS1015_REG_CONFIG_MUX_SINGLE_1;
            break;
        case 2 :
            config |= ADS1015_REG_CONFIG_MUX_SINGLE_2;
            break;
        case 3 :
            config |= ADS1015_REG_CONFIG_MUX_SINGLE_3;
            break;
    }

    // Set 'start single-conversion' bit
    config |= ADS1015_REG_CONFIG_OS_SINGLE;

    // Write config register to the ADC
    writeRegister(ADS1015_REG_POINTER_CONFIG, config);

    // Wait for the conversion to complete
    delay(m_conversionDelay);

    // Read the conversion results
    // Shift 12-bit results right 4 bits for the ADS1015
    return readRegister(ADS1015_REG_POINTER_CONVERT) >> m_bitShift;
}

/**************************************************************************/
/*!
    @brief  Reads the conversion results, measuring the voltage
            difference between the P (AIN0) and N (AIN1) input.  Generates
            a signed value since the difference can be either
            positive or negative.
*/
/**************************************************************************/
function ADS1015::readADC_Differential_0_1()
{
    local res;

    // Start with default values
    config = ADS1015_REG_CONFIG_CQUE_NONE    |  // Disable the comparator (default val)
             ADS1015_REG_CONFIG_CLAT_NONLAT  |  // Non-latching (default val)
             ADS1015_REG_CONFIG_CPOL_ACTVLOW |  // Alert/Rdy active low   (default val)
             ADS1015_REG_CONFIG_CMODE_TRAD   |  // Traditional comparator (default val)
             ADS1015_REG_CONFIG_DR_1600SPS   |  // 1600 samples per second (default)
             ADS1015_REG_CONFIG_MODE_SINGLE;    // Single-shot mode (default)

    // Set PGA/voltage range
    config |= m_gain;

    // Set channels
    config |= ADS1015_REG_CONFIG_MUX_DIFF_0_1;  // AIN0 = P, AIN1 = N

    // Set 'start single-conversion' bit
    config |= ADS1015_REG_CONFIG_OS_SINGLE;

    // Write config register to the ADC
    writeRegister(ADS1015_REG_POINTER_CONFIG, config);

    // Wait for the conversion to complete
    delay(m_conversionDelay);

    // Read the conversion results
    res = readRegister(ADS1015_REG_POINTER_CONVERT) >> m_bitShift;
    if (m_bitShift == 0) {
        return res;
    } else {
        // Shift 12-bit results right 4 bits for the ADS1015,
        // making sure we keep the sign bit intact
        if (res > 0x07FF) {
            // negative number - extend the sign to 16th bit
            res |= 0xF000;
        }
        return res;
    }
}

/**************************************************************************/
/*!
    @brief  Reads the conversion results, measuring the voltage
            difference between the P (AIN2) and N (AIN3) input.  Generates
            a signed value since the difference can be either
            positive or negative.
*/
/**************************************************************************/
function ADS1015::readADC_Differential_2_3()
{
    local res;

    // Start with default values
    config = ADS1015_REG_CONFIG_CQUE_NONE    |  // Disable the comparator (default val)
             ADS1015_REG_CONFIG_CLAT_NONLAT  |  // Non-latching (default val)
             ADS1015_REG_CONFIG_CPOL_ACTVLOW |  // Alert/Rdy active low   (default val)
             ADS1015_REG_CONFIG_CMODE_TRAD   |  // Traditional comparator (default val)
             ADS1015_REG_CONFIG_DR_1600SPS   |  // 1600 samples per second (default)
             ADS1015_REG_CONFIG_MODE_SINGLE;    // Single-shot mode (default)

    // Set PGA/voltage range
    config |= m_gain;

    // Set channels
    config |= ADS1015_REG_CONFIG_MUX_DIFF_2_3;  // AIN2 = P, AIN3 = N

    // Set 'start single-conversion' bit
    config |= ADS1015_REG_CONFIG_OS_SINGLE;

    // Write config register to the ADC
    writeRegister(ADS1015_REG_POINTER_CONFIG, config);

    // Wait for the conversion to complete
    delay(m_conversionDelay);

    // Read the conversion results
    res = readRegister(ADS1015_REG_POINTER_CONVERT) >> m_bitShift;
    if (m_bitShift == 0) {
        return res;
    } else {
        // Shift 12-bit results right 4 bits for the ADS1015,
        // making sure we keep the sign bit intact
        if (res > 0x07FF) {
            // negative number - extend the sign to 16th bit
            res |= 0xF000;
        }
        return res;
    }
}

/**************************************************************************/
/*!
    @brief  Sets up the comparator to operate in basic mode, causing the
            ALERT/RDY pin to assert (go from high to low) when the ADC
            value exceeds the specified threshold.
            This will also set the ADC in continuous conversion mode.
*/
/**************************************************************************/
function ADS1015::startComparator_SingleEnded(channel, threshold)
{
    // Start with default values
    config = ADS1015_REG_CONFIG_CQUE_1CONV   |  // Comparator enabled and asserts on 1 match
             ADS1015_REG_CONFIG_CLAT_LATCH   |  // Latching mode
             ADS1015_REG_CONFIG_CPOL_ACTVLOW |  // Alert/Rdy active low   (default val)
             ADS1015_REG_CONFIG_CMODE_TRAD   |  // Traditional comparator (default val)
             ADS1015_REG_CONFIG_DR_1600SPS   |  // 1600 samples per second (default)
             ADS1015_REG_CONFIG_MODE_CONTIN  |  // Continuous conversion mode
             ADS1015_REG_CONFIG_MODE_CONTIN;    // Continuous conversion mode

    // Set PGA/voltage range
    config |= m_gain;

    // Set single-ended input channel
    switch (channel) {
        case 0 :
            config |= ADS1015_REG_CONFIG_MUX_SINGLE_0;
            break;
        case 1 :
            config |= ADS1015_REG_CONFIG_MUX_SINGLE_1;
            break;
        case 2 :
            config |= ADS1015_REG_CONFIG_MUX_SINGLE_2;
            break;
        case 3 :
            config |= ADS1015_REG_CONFIG_MUX_SINGLE_3;
            break;
    }

    // Set the high threshold register
    // Shift 12-bit results left 4 bits for the ADS1015
    writeRegister(ADS1015_REG_POINTER_HITHRESH, threshold << m_bitShift);

    // Write config register to the ADC
    writeRegister(ADS1015_REG_POINTER_CONFIG, config);
}

/**************************************************************************/
/*!
    @brief  In order to clear the comparator, we need to read the
            conversion results.  This function reads the last conversion
            results without changing the config value.
*/
/**************************************************************************/
function ADS1015::getLastConversionResults()
{
    local res;

    // Wait for the conversion to complete
    delay(m_conversionDelay);

    // Read the conversion results
    res = readRegister(ADS1015_REG_POINTER_CONVERT) >> m_bitShift;
    if (m_bitShift == 0) {
        return res;
    } else {
        // Shift 12-bit results right 4 bits for the ADS1015,
        // making sure we keep the sign bit intact
        if (res > 0x07FF) {
            // negative number - extend the sign to 16th bit
            res |= 0xF000;
        }
        return res;
    }
}

