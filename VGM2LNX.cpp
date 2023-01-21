
#include <iostream>
#include <fstream>
#include <filesystem>
#include <vector>
#include "Ex.hpp"

std::vector<uint8_t> convert( std::vector<uint8_t> const& plain );

int main( int argc, char const* argv[] )
{
  try
  {
    if ( argc < 2 )
    {
      std::cout << "VGM2LNX input.vgm [output.lnx]\n";
      return 1;
    }

    std::filesystem::path path{ argv[1] };
    std::filesystem::path outpath{ argv[ argc < 3 ? 1 : 2] };
    if ( argc < 3 )
      outpath.replace_extension( ".lnx" );

    if ( !std::filesystem::exists( path ) )
    {
      throw Ex{} << "File '" << path.string() << "' does not exist\n";
    }

    size_t size = std::filesystem::file_size( path );

    if ( size == 0 )
    {
      throw Ex{} << "File '" << path.string() << "' is empty\n";
    }

    std::vector<uint8_t> input;
    input.resize( size );

    {
      std::ifstream fin{ path, std::ios::binary };
      fin.read( (char*)input.data(), size );
    }

    auto cvt = convert( input );

    std::ofstream fout{ outpath, std::ios::binary };
    fout.write( (char const*)cvt.data(), cvt.size() );
  }
  catch ( Ex const& ex )
  {
    std::cerr << ex.what() << std::endl;
    return -1;
  }
}
