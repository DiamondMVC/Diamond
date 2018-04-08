/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.postaladdress;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.schemaobject;

  /// http://schema.org/PostalAddress
  final class PostalAddress : SchemaObject
  {
    private:
    /// The address locality.
    string _addressLocality;
    /// The postal code.
    string _postalCode;
    /// The street address.
    string _streetAddress;
    /// The address region.
    string _addressRegion;
    /// The address country.
    string _addressCountry;
    /// The name.
    string _name;
    /// The post office box number.
    string _postOfficeBoxNumber;

    public:
    final:
    /// Creates a new postal address.
    this()
    {
      super("PostalAddress");
    }

    @property
    {
      /// Gets the address locality.
      string addressLocality() { return _addressLocality; }

      /// Sets the address locality.
      void addressLocality(string newAddressLocality)
      {
        _addressLocality = newAddressLocality;

        super.addField("addressLocality", _addressLocality);
      }

      /// Gets the postal code.
      string postalCode() { return _postalCode; }

      //// Sets the postal code.
      void postalCode(string newPostalCode)
      {
        _postalCode = newPostalCode;

        super.addField("postalCode", _postalCode);
      }

      /// Gets the street address.
      string streetAddress() { return _streetAddress; }

      /// Sets the street address.
      void streetAddress(string newStreetAddress)
      {
        _streetAddress = newStreetAddress;

        super.addField("streetAddress", _streetAddress);
      }

      /// Gets the address region.
      string addressRegion() { return _addressRegion; }

      /// Sets the address region.
      void addressRegion(string newAddressRegion)
      {
        _addressRegion = newAddressRegion;

        super.addField("addressRegion", _addressRegion);
      }

      /// Gets the address country.
      string addressCountry() { return _addressCountry; }

      /// Sets the address country.
      void addressCountry(string newAddressCountry)
      {
        _addressCountry = newAddressCountry;

        super.addField("addressCountry", _addressCountry);
      }

      /// Gets the name.
      string name() { return _name; }

      /// Sets the name.
      void name(string newName)
      {
        _name = newName;

        super.addField("name", _name);
      }

      /// Gets the post office box number.
      string postOfficeBoxNumber() { return _postOfficeBoxNumber; }

      /// Sets the post office box number.
      void postOfficeBoxNumber(string newPostOfficeBoxNumber)
      {
        _postOfficeBoxNumber = newPostOfficeBoxNumber;

        super.addField("postOfficeBoxNumber", _postOfficeBoxNumber);
      }
    }
  }
}
