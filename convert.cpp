#include <vector>
#include <array>
#include <cassert>
#include "vgmplay.h"
#include "rational.hpp"
#include "Ex.hpp"
#include <iostream>

template<typename T>
static T value( std::vector<uint8_t> const& plain, size_t off )
{
  return *(T const*)&plain[off];
}

struct TimerUpdate
{
  uint8_t timer7Count;
  uint8_t timer5Backup;
  uint8_t timer5Sale;


  static TimerUpdate create( int64_t cycles );

  TimerUpdate();

  int64_t cycles() const;
  int64_t timer5Cycle() const;
  explicit operator bool() const;

private:
  TimerUpdate( int64_t cycles, uint8_t initialTimer7Count );

  static uint8_t toScale( int mult );
  static int toMult( uint8_t scale );
};

using Rational = rational::Rational64;

class Image
{
  static constexpr uint8_t FLAG_FILL_MIKEY = 0x80;
  static constexpr uint8_t FLAG_FILL_MEMORY = 0x40;
  static constexpr uint8_t FLAG_CHANGE_SECTOR = 0x20;
  static constexpr uint8_t FLAG_JSR = 0x10;
  static constexpr uint8_t FLAG_REPEAT = 0x08;
  static constexpr int SECTOR_SIZE = 2048;

  struct Sector
  {
    std::array<uint8_t, SECTOR_SIZE> data;
    int fill = 0;

    void push_back( uint8_t value )
    {
      data[fill++] = value;
    }

    int free() const
    {
      return SECTOR_SIZE - fill;
    }
  };

  struct WriteMikey
  {
    uint8_t addr;
    uint8_t value;
  };

  struct Header
  {
    std::array<char, 4>   magic = { 'L','Y','N','X' };
    uint16_t                 pageSizeBank0 = 0x800;
    uint16_t                 pageSizeBank1 = 0;
    uint16_t                 version = 1;
    std::array<char, 32>     cartname = {};
    std::array<char, 16>     manufname = {};
    uint8_t                  rotation = {};
    uint8_t                  audBits = {};
    uint8_t                  eepromBits = {};
    std::array<uint8_t, 3>   spare = {};
  } mHeader{};

public:

  Image();
  void writeMikey( uint8_t addr, uint8_t value );
  void startLoop();
  void endLoop();
  void wait( int samples );
  int32_t loopLength() const;

  std::vector<uint8_t> result() const;

private:

  class TempBuffer
  {
  public:
    TempBuffer( Image& image );
    ~TempBuffer();

    TimerUpdate wait( Rational diff );
    void write( WriteMikey wm );

  private:
    void commit( bool final );

  private:
    Image& mImage;
    std::vector<WriteMikey> mData;
    bool mWaiting;
  };

  int lastSectorFree() const;
  bool append( std::vector<uint8_t> const& data );
  void push_back( uint8_t data );
  void addSector();
  void changeSector( uint8_t sector = 0 );
  int currentSectorNumber() const;


private:

  std::vector<Sector> mSectors = {};

  int mLoopStartSector = -1;
  int mLoopSamples = -1;
  std::vector<WriteMikey> mWrites = {};
  Rational mIdealTime{};
  Rational mRealTime{};
  TimerUpdate mLastTimerUpdate{};

};

std::vector<uint8_t> convert( std::vector<uint8_t> const& plain )
{
  if ( std::string{ (char const*)plain.data(), 4 } != "Vgm " )
  {
    throw Ex{} << "Not a VGM file";
  }

  if ( value<uint32_t>( plain, 0x08 ) < 0x172 )
  {
    throw Ex{} << "Not a VGM version 1.72 file";
  }

  uint32_t mikeyFreq = value<uint32_t>( plain, 0xe4 );

  if ( mikeyFreq == 0 )
  {
    throw Ex{} << "Not a VGM with Atari Lynx support";
  }

  uint32_t loopOffset = value<uint32_t>( plain, 0x1c );
  if ( loopOffset )
    loopOffset += 0x1c;
  int32_t loopSamples = value<int32_t>( plain, 0x20 );
  uint32_t dataOffset = value<uint32_t>( plain, 0x34 ) + 0x34;
  uint32_t eofOffset = value<uint32_t>( plain, 0x04 ) + 0x04;
  uint32_t gd3Offset = value<uint32_t>( plain, 0x14 ) + 0x14;


  Image image;

  for ( size_t i = dataOffset; i < eofOffset; )
  {
    if ( i == loopOffset )
    {
      image.startLoop();
    }

    uint8_t cmd = plain[i++];

    if ( image.loopLength() >= loopSamples )
    {
      image.endLoop();
      break;
    }

    if ( cmd == 0x40 )
    {
      uint8_t reg = plain[i++];
      uint8_t val = plain[i++];
      image.writeMikey( reg, val );
    }
    else if ( cmd == 0x61 )
    {
      int wait = value<uint16_t>( plain, i );
      i += 2;
      image.wait( wait );
    }
    else if ( cmd == 0x62 )
    {
      image.wait( 735 );
    }
    else if ( cmd == 0x63 )
    {
      image.wait( 882 );
    }
    else if ( ( cmd >> 4 ) == 0x7 )
    {
      int wait = ( cmd & 0xf ) + 1;
      image.wait( wait );
    }
    else if ( cmd == 0x66 )
    {
      //silence
      image.writeMikey( 0x20, 0 );
      image.writeMikey( 0x25, 0 );
      image.writeMikey( 0x28, 0 );
      image.writeMikey( 0x2d, 0 );
      image.writeMikey( 0x30, 0 );
      image.writeMikey( 0x35, 0 );
      image.writeMikey( 0x38, 0 );
      image.writeMikey( 0x3d, 0 );
      image.wait( 0 );
      break;
    }
  }

  return image.result();
}

Image::Image()
{
  addSector();
  std::copy_n( vgmplay_bin, vgmplay_bin_len, mSectors.back().data.data() );
  addSector();
}

void Image::writeMikey( uint8_t addr, uint8_t value )
{
  mWrites.push_back( { addr, value } );
}

void Image::startLoop()
{
  if ( lastSectorFree() != SECTOR_SIZE )
  {
    changeSector();
    mLoopStartSector = currentSectorNumber();
    mLoopSamples = 0;
  }
}

void Image::endLoop()
{
  changeSector( mLoopStartSector );
}

void Image::wait( int samples )
{
  mIdealTime += Rational{ samples, 44100 };

  if ( mLoopSamples >= 0 )
    mLoopSamples += samples;

  TempBuffer buf{ *this };

  auto diff = mIdealTime - mRealTime;
  if ( diff > 0 )
  {
    TimerUpdate newTimerUpdate = buf.wait( diff );
    mRealTime += Rational{ newTimerUpdate.cycles() + mLastTimerUpdate.timer5Cycle(), 1000000 };
    mLastTimerUpdate = newTimerUpdate;
  }

  for ( auto const& write : mWrites )
  {
    buf.write( write );
  }

  mWrites.clear();
}

int32_t Image::loopLength() const
{
  return mLoopSamples;
}

std::vector<uint8_t> Image::result() const
{
  std::vector<uint8_t> result;

  std::copy_n( (uint8_t const*)&mHeader, sizeof( mHeader ), std::back_inserter( result ) );

  for ( auto const& sector : mSectors )
  {
    std::copy_n( sector.data.data(), sector.data.size(), std::back_inserter( result ) );
  }

  return result;
}

int Image::lastSectorFree() const
{
  return mSectors.back().free();
}

bool Image::append( std::vector<uint8_t> const& data )
{
  int free = lastSectorFree();

  if ( free < data.size() )
  {
    throw Ex{} << "Internal error";
  }

  for ( uint8_t byte : data )
    push_back( byte );

  return true;
}

void Image::push_back( uint8_t data )
{
  mSectors.back().push_back( data );
}

void Image::addSector()
{
  mSectors.emplace_back();
}

void Image::changeSector( uint8_t sector )
{
  int free = lastSectorFree();

  assert( free >= 2 );
  push_back( FLAG_CHANGE_SECTOR );
  push_back( sector ? sector : (uint8_t)( currentSectorNumber() + 1 ) );
  if ( !sector )
    addSector();
}

int Image::currentSectorNumber() const
{
  return (int)( mSectors.size() - 1 );
}

Image::TempBuffer::TempBuffer( Image& image ) : mImage{ image }, mData{}, mWaiting{}
{
}

Image::TempBuffer::~TempBuffer()
{
  commit( mWaiting );
}

TimerUpdate Image::TempBuffer::wait( Rational diff )
{
  static constexpr uint8_t TIMER5_BACKUP = 0x14;
  static constexpr uint8_t TIMER5_CONTROLA = 0x15;
  static constexpr uint8_t TIMER7_CONTROLA = 0x1d;
  static constexpr uint8_t TIMER7_COUNT  = 0x1e;
  static constexpr uint8_t ENABLE_INT    = 0b10000000;
  static constexpr uint8_t RESET_DONE    = 0b01000000;
  static constexpr uint8_t ENABLE_RELOAD = 0b00010000;
  static constexpr uint8_t ENABLE_COUNT  = 0b00001000;
  static constexpr uint8_t AUD_LINKING   = 0b00000111;

  if ( mWaiting )
  {
    commit( true );
  }

  TimerUpdate timerUpdate = TimerUpdate::create( Rational::to_integer( diff * 1000000 ) );

  write( { TIMER7_COUNT, timerUpdate.timer7Count } );
  write( { TIMER7_CONTROLA, (uint8_t)( ENABLE_INT | RESET_DONE | ENABLE_COUNT | AUD_LINKING ) } );
  write( { TIMER5_BACKUP, timerUpdate.timer5Backup } );
  write( { TIMER5_CONTROLA, (uint8_t)( ENABLE_RELOAD | ENABLE_COUNT | (uint8_t)timerUpdate.timer5Sale ) } );

  mWaiting = true;
  return timerUpdate;
}

void Image::TempBuffer::write( WriteMikey wm )
{
  int free = mImage.lastSectorFree();

  if ( free < ( mData.size() + 1 ) * 2 + 1 /*cmd*/ + 1 /*fill_mikey*/ + 2 /*change sector*/ + 2 /*reserve for next sector*/ )
  {
    commit( false );
  }

  mData.push_back( wm );
}

void Image::TempBuffer::commit( bool final )
{
  std::vector<uint8_t> data;
  bool sectorChanged = false;

  int free = mImage.lastSectorFree();

  data.push_back( final ? 0 : FLAG_REPEAT );
  if ( !mData.empty() )
    data.front() |= FLAG_FILL_MIKEY;

  if ( !mData.empty() )
  {
    //TODO check whether there no more that 255 writes
    data.push_back( (uint8_t)mData.size() );
    for ( auto const& mw : mData )
    {
      data.push_back( mw.addr );
      data.push_back( mw.value );
    }
  }

  if ( free - 4 <= data.size() )
  {
    data.front() |= FLAG_CHANGE_SECTOR;
    data.push_back( (uint8_t)( mImage.currentSectorNumber() + 1 ) );
    sectorChanged = true;
  }

  mImage.append( data );

  if ( sectorChanged )
    mImage.addSector();

  mData.clear();
  mWaiting = false;
}

TimerUpdate TimerUpdate::create( int64_t cycles )
{
  TimerUpdate candidate{};
  int64_t candidateError = cycles;

  for ( int t7 = 255; t7 >= 0; --t7 )
  {
    TimerUpdate cand{ cycles, (uint8_t)t7 };
    if ( cand )
    {
      int64_t err = std::abs( cand.cycles() - cycles );
      if ( err < candidateError )
      {
        candidateError = err;
        candidate = cand;
      }

      if ( candidateError == 0 )
        break;
    }
  }
  return candidate;
}

TimerUpdate::TimerUpdate() : timer7Count{}, timer5Backup{}, timer5Sale{}
{
}

TimerUpdate::TimerUpdate( int64_t cycles, uint8_t initialTimer7Count ) : timer7Count{ initialTimer7Count }, timer5Backup{}, timer5Sale{}
{
  int64_t t5cummulative = cycles / ( initialTimer7Count + 1 );

  for ( timer5Sale = 0; timer5Sale < 7; ++timer5Sale )
  {
    auto t5 = t5cummulative / toMult( timer5Sale ) - 1;
    if ( t5 > 0 && t5 < 256 )
    {
      timer5Backup = (uint8_t)t5;
      break;
    }
  }
}

int64_t TimerUpdate::cycles() const
{
  return ( timer5Cycle() + 1 ) * ( timer7Count + 1 );
}

int64_t TimerUpdate::timer5Cycle() const
{
  return timer5Backup * toMult( timer5Sale );
}

TimerUpdate::operator bool() const
{
  return timer5Backup != 0;
}

uint8_t TimerUpdate::toScale( int mult )
{
  int scale = 0;
  while ( mult > 1 )
  {
    scale += 1;
    mult >>= 1;
  }

  assert( scale < 7 );

  return (uint8_t)scale;
}

int TimerUpdate::toMult( uint8_t scale )
{
  return 1 << (int)scale;
}
