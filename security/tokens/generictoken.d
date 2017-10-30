/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.tokens.generictoken;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.security.tokens.tokengenerator;

  /// Wrapper for a generic token generator.
  final class GenericToken : TokenGenerator
  {
    import vibe.crypto.cryptorand;

    private:
    /// The random generator for the generic token. TODO: Better RNG implementation ...
    SHA1HashMixerRNG _randomGenerator;

    /// Creates a new generic token generator.
    this()
    {
      super();

      _randomGenerator = new SHA1HashMixerRNG;
    }

    public:
    final:
    /**
    * Generates a token.
    * Returns:
    *   Returns the generated token.
    */
    override string generate()
    {
      import diamond.core.senc;

      ubyte[64] randomBuffer;
      _randomGenerator.read(randomBuffer);

      return SENC.encode(randomBuffer);
    }

    /**
    * Generates a token. The input is ignored.
    * Params:
    *   input = Discarded for generic tokens.
    * Returns:
    *   Returns the generated token.
    */
    override string generate(string input)
    {
      return generate();
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

  /// The generic token instance for the current thread.
  private GenericToken _genericToken;

  @property
  {
    /// Gets the generic token generator.
    GenericToken genericToken()
    {
      if (!_genericToken)
      {
        _genericToken = new GenericToken;
      }

      return _genericToken;
    }
  }
}
