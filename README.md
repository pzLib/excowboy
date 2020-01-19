# ExCowboy

ExCowboy is an extended cowboy library.

As we know, cowboy will return 500 code to http client automatically and without any details if it meet an exception.
Excowboy_handler catches these exceptions and enables you handle them in except callback, 
then you can return error details or/and reset http status code in one place.  

## How To Use

There is an example in examples directory. 