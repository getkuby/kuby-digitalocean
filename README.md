## kuby-digitalocean

DigitalOcean provider for [Kuby](https://github.com/getkuby/kuby-core).

## Intro

In Kuby parlance, a "provider" is an [adapter](https://en.wikipedia.org/wiki/Adapter_pattern) that enables Kuby to deploy apps to a specific cloud provider. In this case, we're talking about [DigitalOcean](https://www.digitalocean.com/).

All providers adhere to a specific interface, meaning you can swap out one provider for another without having to change your code.

## Usage

Enable the DigitalOcean provider like so:

```ruby
Kuby.define(:production) do
  kubernetes do

    provider :digitalocean do
      access_token 'my-digitalocean-access-token'
      cluster_id 'my-cluster-id'
    end

  end
end
```

Once configured, you should be able to run all the Kuby rake tasks as you would with any provider.

## License

Licensed under the MIT license. See LICENSE for details.

## Authors

* Cameron C. Dutro: http://github.com/camertron
