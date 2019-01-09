/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.offer;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.schemaobject;

  /// http://schema.org/ItemAvailability
  enum ItemAvailability : string
  {
    /// Discontinued.
    discontinued = "http://schema.org/Discontinued",

    /// In stock.
    inStock = "http://schema.org/InStock",

    /// In store only.
    inStoreOnly = "http://schema.org/InStoreOnly",

    /// Limited availability.
    limitedAvailability = "http://schema.org/LimitedAvailability",

    /// Online only.
    onlineOnly = "http://schema.org/OnlineOnly",

    /// Out of stock.
    outOfStock = "http://schema.org/OutOfStock",

    /// Pre order.
    preOrder = "http://schema.org/PreOrder",

    /// Pre sale.
    preSale = "http://schema.org/PreSale",

    /// Sold out.
    soldOut = "http://schema.org/SoldOut"
  }

  /// http://schema.org/Offer
  final class Offer : SchemaObject
  {
    private:
    /// The price.
    string _price;
    /// The price currency.
    string _priceCurrency;
    /// The url.
    string _url;
    /// The availability.
    ItemAvailability _availability;

    public:
    final:
    /// Creates a new offer.
    this()
    {
      super("Offer");
    }

    @property
    {
      /// Gets the price.
      string price() { return _price; }

      /// Sets the price.
      void price(string newPrice)
      {
        _price = newPrice;

        super.addField("price", _price);
      }

      /// Gets the price currency.
      string priceCurrency() { return _priceCurrency; }

      /// Sets the price currency.
      void priceCurrency(string newPriceCurrency)
      {
        _priceCurrency = newPriceCurrency;
      }

      /// Gets the url.
      string url() { return _url; }

      /// Sets the url.
      void url(string newUrl)
      {
        _url = newUrl;

        super.addField("url", _url);
      }

      /// Gets the availability.
      ItemAvailability availability() { return _availability; }

      /// Sets the availability.
      void availability(ItemAvailability newAvailability)
      {
        _availability = newAvailability;

        super.addField("availability", cast(string)_availability);
      }
    }
  }
}
