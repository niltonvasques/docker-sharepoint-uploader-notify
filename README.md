# Mailing Sharepoint Storage Docker Container

### This script upload a file to sharepoint and send a mail with this file link

### Usage

        docker run -it --rm -e FROM='test@gmail.com' -e TO='test@gmail.com' -e SUBJECT='topic' -e SHAREPOINT_LOGIN='user@mail.com' -e SHAREPOINT_PASS='pass' -e MAIL_PASS='pass' -e SHAREPOINT_URL='sharepoint.com' -e SHAREPOINT_SITE='site' -e SHAREPOINT_FOLDER='folder' -e FILE_NAME='test.file' -v $PWD:/tmp/ --name mail-app mail-sharepoint-storage
