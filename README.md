<div align="center">
	<p>
		<img alt="Thoughtworks Logo" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/thoughtworks_flamingo_wave.png?sanitize=true" width=200 />
    <br />
		<img alt="DPS Title" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/EMPCPlatformStarterKitsImage.png?sanitize=true" width=350/>
	</p>
  <h3>EMPC Helm Chart Registry</h3>
  <a href="https://app.circleci.com/pipelines/github/ThoughtWorks-DPS/circleci-kube-ops"><img src="https://circleci.com/gh/ThoughtWorks-DPS/circleci-kube-ops.svg?style=shield"></a> <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/github/license/ThoughtWorks-DPS/circleci-kube-ops"></a>
</div>
<br />

## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to Helm's [documentation](https://helm.sh/docs) to get started.  

Once Helm has been set up correctly, add the repo as follows:  

```bash
$ helm repo add twdps https://ThoughtWorks-DPS.github.io/helm-charts
```

If you had already added this repo earlier, run `helm repo update` to retrieve the latest versions of the packages. You can then run `helm search repo twdps` to see the charts.  

### example  

To install the opa-sidecar-injector chart:  
```bash
$ helm install opa-sidecar-admission-controller thoughtworks-dps/opa-sidecar-admission-controller  
```
To uninstall the chart:  
```bash
$ helm delete opa-sidecar-admission-controller
```
