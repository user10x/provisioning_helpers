import * as pulumi from "@pulumi/pulumi";
import * as gcp from "@pulumi/gcp";
import {config} from "@pulumi/gcp";

// Create a GCP resource (Storage Bucket)
// const bucket = new gcp.storage.Bucket("my-bucket", {
//     location: "US"
// });
//
// // Export the DNS name of the bucket
// export const bucketName = bucket.url;

// create a service account
const serviceAccount = new gcp.serviceaccount.Account("service-account", {
    accountId: "oc-appy-service-account",
    project: config.project,

});

// create a cloud run service

const app = 'oc-appy';
const serviceName = `${app}`;
const image = "gcr.io/cloudrun/hello";

const serviceArgs: gcp.cloudrun.ServiceArgs = {
    name: serviceName,
    location: "us-west2",
    template: {
        spec: {
            serviceAccountName: serviceAccount.email,
            containers: [
                {
                    image: image,
                    envs: [
                        {
                            name: 'ENVIRONMENT_NAME',
                            value: "dev",
                    }],
                },
            ],
        }
    }
}

const service = new gcp.cloudrun.Service(app, serviceArgs);

// create a scheduler for this service
const job = new gcp.cloudscheduler.Job("oc-appy-job", {
    attemptDeadline: "320s",
    region: "us-west2",
    name: "oc-appy-job",
    description: "test oidc token",
    retryConfig: {
        maxDoublings: 2,
        maxRetryDuration: "10s",
        minBackoffDuration: "1s",
        retryCount: 3,
    },
    schedule: "*/4 * * * *",
    timeZone: "America/Los_Angeles",
    httpTarget: {
        uri: service.statuses[0].url,
        httpMethod: "GET",
        oidcToken: {
            serviceAccountEmail: serviceAccount.email,
        }
    }
});


const ip = new gcp.compute.Address("oc-appy-ip", {
    name: "oc-appy-ip",
    region: "us-west2",
    addressType: "EXTERNAL",
    project: config.project,
});


const endpointGroup = new gcp.compute.RegionNetworkEndpointGroup("oc-appy-endpoint-group", {
    name: "oc-appy-endpoint-group",
    region: "us-west2",
    project: config.project,
    networkEndpointType: "SERVERLESS",
    cloudRun: {
        service: service.name,
    }});


const backendService = new gcp.compute.BackendService("oc-appy-endpoint-group", {
    name: "oc-appy-endpoint-group",
    project: config.project,
    backends: [{
        group: endpointGroup.id,
    }],
    });


const urlMap = new gcp.compute.URLMap("oc-appy-url-map", {
    name: "oc-appy-url-map",
    project: config.project,
    defaultService: backendService.id,
});



const certificate = new gcp.compute.ManagedSslCertificate(
    'my-customdomain-certificate',
    {
        managed: {
            domains: ['nipun.brainos.com'],
        },
    }
)

const httpsProxy = new gcp.compute.TargetHttpsProxy("oc-appy-https-proxy", {
    name: "oc-appy-https-proxy",
    project: config.project,
    urlMap: urlMap.id,
    sslCertificates: [certificate.id],
});



// create a loadbalancer
const lb = new gcp.compute.GlobalForwardingRule("oc-appy-lb", {
    name: "oc-appy-lb",
    ipAddress: ip.address,
    ipProtocol: "TCP",
    portRange: "443",
    target: httpsProxy.selfLink,
    loadBalancingScheme: "EXTERNAL",
});


export const url = pulumi.interpolate`https://${ip.address}/`;
