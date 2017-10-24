/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.sessiontoken;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.security.tokengenerator;

  /// Wrapper for a session token generator.
  final class SessionToken : TokenGenerator
  {
    private:
    /// Creates a new instance of the session token generator.
    this()
    {
      super();
    }

    public:
    /**
    * Generates a token.
    * Returns:
    *   Returns the generated token.
    */
    override string generate()
    {
      import diamond.security.generictoken;

      return genericToken.generate();
    }

    /**
    * Generates a token based on an input.
    * Params:
    *   input = An input to append to the token.
    * Returns:
    *   Returns the generated token.
    */
    override string generate(string input)
    {
      import diamond.core.senc;

      return generate() ~ SENC.encode(input);
    }

    /**
    * Generates a token and passes it to the parent generator.
    * Params:
    *   parentGenerator = The parent generator to use with the generated token.
    * Returns:
    *   Returns the generated token.
    */
    override string generate(TokenGenerator parentGenerator)
    {
      import diamond.errors.checks;
      enforce(parentGenerator, "Passed no parent generator.");

      return parentGenerator.generate(this.generate());
    }
  }

  /// The session token generator instance for the current thread.
  private SessionToken _sessionToken;

  @property
  {
    /// Gets the session token.
    SessionToken sessionToken()
    {
      if (!_sessionToken)
      {
        _sessionToken = new SessionToken;
      }

      return _sessionToken;
    }
  }
}
