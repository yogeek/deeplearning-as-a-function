import os, json, time, tempfile, sys, io, urllib, requests, contextlib, humanize

from minio import Minio
from minio.error import ResponseError

   
minioClient = Minio(os.environ['minio_hostname'],
                 access_key=os.environ['minio_access_key'],
                 secret_key=os.environ['minio_secret_key'],
                 secure=False)

bucket_input = os.environ['bucket_input']

faasIP = 'gateway'
faasPort = '8080'
faasGatewayUrl = 'http://'+faasIP+':'+faasPort+'/function/'
faasYoloFunction = 'yolo'


# JSON pretty print (json_thing = str or dict)
def pp_json(json_thing, sort=True, indents=4):
    if type(json_thing) is str:
        print(json.dumps(json.loads(json_thing), sort_keys=sort, indent=indents))
    else:
        print(json.dumps(json_thing, sort_keys=sort, indent=indents))
    return None    

# This class listens to a Minio bucket events and launch an openfaas function when a new file is added
def listenInputBucket(bucket_input, prefix='', suffix=''):
    try:
        print('Listening for file creation in minio bucket...')
        while True:
            # Listen creation notifications in input bucket
            events = minioClient.listen_bucket_notification(bucket_input, prefix, suffix, ['s3:ObjectCreated:*'])
            for event in events:
                #pp_json(event)
                if event['Records'][0]['eventName'] == "s3:ObjectCreated:Put":
                    object = event['Records'][0]['s3']['object']
                    input_file_name = object['key']
                    input_file_type = object['contentType']
                    input_file_size = humanize.naturalsize(object['size'])
                    input_file_etag = object['eTag']
                    if input_file_type.startswith("image/"):
                        print("New image detected : %s (size=%s)" % (input_file_name, input_file_size))

                        # TODO : send more information in JSON format to the next function
                        #json_data = {
                        #    "image": input_file_name,
                        #    "output_filename": filename_out
                        #}
                        #r = requests.post('http://gateway:8080/async-function/yolo', json=json_data)

                        # Send image location to yolo function
                        r = requests.post(faasGatewayUrl + faasYoloFunction, input_file_name)
                        if (r.status_code == requests.codes['\o/']):
                            print("Prediction succeeded for -> " + input_file_name)
                            # TODO : Move predicted file to an archive bucket ?
                            # minioClient.get_object(bucket_name, input_file_name)
                        else:
                            print("Prediction failed for -> " + input_file_name + " Status code = " + str(r.status_code))

    except Exception as e:
        print("error damnit", e)

        
if __name__ == '__main__':
    print('Setting up')
    listenInputBucket(bucket_input)
    print('End')
