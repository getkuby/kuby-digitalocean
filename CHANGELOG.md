## 0.4.3
* Add a unique hash of the configuration options to the kubeconfig path (#3, @pandwoter)

## 0.4.2
* Avoid `instance_eval`ing a `nil` block during configuration.

## 0.4.1
* Fix bug causing kubeconfig to not get refreshed prior to executing commands.

## 0.4.0
* Accept `environment` instead of `definition` instances.

## 0.3.0
* Refresh kubeconfig in more places.
  - Before setup
  - Before deploy

## 0.2.0
* Refresh kubeconfig earlier and more often so it's ready during setup.

## 0.1.0
* Birthday!
