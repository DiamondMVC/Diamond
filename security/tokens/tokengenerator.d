/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.tokens.tokengenerator;

import diamond.core.apptype;

static if (isWeb)
{
  /// Wrapper for a token generator.
  abstract class TokenGenerator
  {
    protected:
    /// Creates a new instance of the token generator.
    this() { }

    public:
    /**
    * Generates a token.
    * Returns:
    *   Returns the generated token.
    */
    abstract string generate();

    /**
    * Generates a token based on an input.
    * Params:
    *   input = The input to generate the token based on.
    * Returns:
    *   Returns the generated token.
    */
    abstract string generate(string input);

    /**
    * Generates a token and passes it to the parent generator.
    * Params:
    *   parentGenerator = The parent generator to use with the generated token.
    * Returns:
    *   Returns the generated token.
    */
    abstract string generate(TokenGenerator parentGenerator);
  }
}
