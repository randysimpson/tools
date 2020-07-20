//App to get the required info from an exported json in k8s to restore.
const fs = require('fs')
const yaml = require('js-yaml');


const secrets = require('./secrets.json');
const pv = require('./pv.json');
const pvc = require('./pvc.json');
const deployments = require('./depolyments.json');
const statefulSets = require('./statefulset.json');
const services = require('./service.json');

const storeData = (data, path) => {
  try {
    fs.writeFileSync(path, JSON.stringify(data))
  } catch (err) {
    console.error(err)
  }
}

const loadData = (path) => {
  try {
    return fs.readFileSync(path, 'utf8')
  } catch (err) {
    console.error(err)
    return false
  }
}

//console.log(deployments);
//console.log(secrets);

/*for(let i =0; i < secrets.items.length; i++) {
  console.log(secrets.items[i].metadata.name);
}*/

let newSecrets = secrets.items.filter((item) => !item.metadata.name.startsWith("default-token")).map((item) => {
  let newItem = {
    apiVersion: item.apiVersion,
    data: item.data,
    kind: item.kind,
    type: item.type,
    metadata: {}
  }
  newItem.metadata.name = item.metadata.name;
  newItem.metadata.namespace = item.metadata.namespace;
  return newItem;
});
//console.log(newSecrets);

//storeData(newSecrets, './newSecrets.json');

let yamlStr = newSecrets.map((item) => yaml.safeDump(item)).join("---\n");
//fs.writeFileSync('newSecrets.yaml', yamlStr, 'utf8');

let newPv = pv.items.map((item) => {
  let newItem = {
    apiVersion: item.apiVersion,
    kind: item.kind,
    spec: item.spec,
    metadata: {}
  }
  delete newItem.spec.claimRef;
  newItem.metadata.labels = item.metadata.labels;
  newItem.metadata.name = item.metadata.name;
  return newItem;
});

//console.log(newPv);
yamlStr = newPv.map((item) => yaml.safeDump(item)).join("---\n");
fs.writeFileSync('newPv.yaml', yamlStr, 'utf8');

let newPvc = pvc.items.map((item) => {
  let newItem = {
    apiVersion: item.apiVersion,
    kind: item.kind,
    spec: item.spec,
    metadata: {}
  };
  newItem.metadata.labels = item.metadata.labels;
  newItem.metadata.name = item.metadata.name;
  newItem.metadata.namespace = item.metadata.namespace;
  return newItem;
});

//console.log(newPvc);
yamlStr = newPvc.map((item) => yaml.safeDump(item)).join("---\n");
fs.writeFileSync('newPvc.yaml', yamlStr, 'utf8');

let newStatefulSet = statefulSets.items.map((item) => {
  let newItem = {
    apiVersion: item.apiVersion,
    kind: item.kind,
    metadata: item.metadata,
    spec: item.spec
  };
  delete newItem.metadata.creationTimestamp;
  delete newItem.metadata.generation;
  delete newItem.metadata.managedFields;
  delete newItem.metadata.resourceVersion;
  delete newItem.metadata.selfLink;
  delete newItem.metadata.uid;
  delete newItem.spec.template.metadata.creationTimestamp;
  newItem.spec.volumeClaimTemplates = item.spec.volumeClaimTemplates.map((item) => {
    return {
      metadata: {
        name: item.metadata.name
      },
      spec: item.spec
    }
  });
  return newItem;
});

//console.log(newStatefulSet);
yamlStr = newStatefulSet.map((item) => yaml.safeDump(item)).join("---\n");
fs.writeFileSync('newStatefulset.yaml', yamlStr, 'utf8');

let newDeployments = deployments.items.map((item) => {
  let newItem = {
    apiVersion: item.apiVersion,
    kind: item.kind,
    metadata: item.metadata,
    spec: item.spec
  }
  delete newItem.metadata.annotations;
  delete newItem.metadata.creationTimestamp;
  delete newItem.metadata.managedFields;
  delete newItem.metadata.resourceVersion;
  delete newItem.metadata.selfLink;
  delete newItem.metadata.uid;
  delete newItem.spec.template.metadata.creationTimestamp;
  return newItem;
});

//console.log(newDeployments);
yamlStr = newDeployments.map((item) => yaml.safeDump(item)).join("---\n");
fs.writeFileSync('newDeployment.yaml', yamlStr, 'utf8');

let newService = services.items.filter((item) => item.metadata.name !== "kubernetes").map((item) => {
  let newItem = {
    apiVersion: item.apiVersion,
    kind: item.kind,
    metadata: item.metadata,
    spec: item.spec
  };
  delete newItem.metadata.creationTimestamp;
  delete newItem.metadata.managedFields;
  delete newItem.metadata.resourceVersion;
  delete newItem.metadata.selfLink;
  delete newItem.metadata.uid;
  delete newItem.spec.clusterIP;
  return newItem;
});

//console.log(newService);
yamlStr = newService.map((item) => yaml.safeDump(item)).join("---\n");
fs.writeFileSync('newService.yaml', yamlStr, 'utf8');

//need to add configmaps