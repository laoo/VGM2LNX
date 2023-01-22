#pragma once

#include <exception>
#include <memory>
#include <sstream>

class Ex : public std::exception
{
public:

  Ex() : exception{}, mSS{ std::make_shared<std::stringstream>() }, mStr{}
  {
  }

  template<typename T>
  Ex& operator<<( T const& t )
  {
    *mSS << t;
    return *this;
  }

  char const* what() const noexcept
  {
    mStr = mSS->str();
    return mStr.c_str();
  }

private:
  std::shared_ptr<std::stringstream> mSS;
  mutable std::string mStr;
};

