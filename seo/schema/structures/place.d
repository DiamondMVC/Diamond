/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.place;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.schemaobject;
  import diamond.seo.schema.structures.postaladdress;

  /// http://schema.org/Place
  final class Place : SchemaObject
  {
    private:
    /// The name.
    string _name;
    /// The address.
    PostalAddress _address;

    public:
    final:
    /// Creates a new place.
    this()
    {
      super("Place");
    }

    @property
    {
      /// Gets the name.
      string name() { return _name; }

      /// Sets the name.
      void name(string newName)
      {
        _name = newName;
      }

      /// Gets the address.
      PostalAddress address() { return _address; }

      /// Sets the address.
      void address(PostalAddress newAddress)
      {
        _address = newAddress;

        super.addField("address", _address);
      }
    }
  }
}
