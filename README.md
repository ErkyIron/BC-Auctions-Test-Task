# BC-Auctions-Test-Task
The repository will include the code for implementation of Test task related to Auctions Information API.

Implementaion is done based on Business Central Version 26.0. The app name is API Auctions Info.

To be able to test the app you will need to install the app into the BC environment. In case you do not have any, you can create docker container with bc-w1 version to test it. The script for the docker creation can be found in folder scripts. 

You will need to open the power shell in administration mode and run the script CreateDockerW1.ps1 to be ablle to create new container.

# App "API Auctions Info" facilities
The "API Auctions Info" app provides integration with an external Auctions Information API for Microsoft Dynamics 365 Business Central (version 26.0). 
Its main facilities include:
- Receiving auction information from an external service.
- Parsing and saving auction data into Business Central tables.
- Managing auction details such as Auction No., Negotiation No., Contact Info, Auction Url, and Internal Notes.
- New functionality can be added in future

# App "API Auctions Info" limitations
The app "API Auctions Info" has the following limitations:
- Only supports integration with a single external Auctions Information API as currently configured.
- Requires Microsoft Dynamics 365 Business Central version 26.0; earlier versions are not supported.
- Assumes the external API response structure remains consistent; changes in the API may require code updates.
- Does not include advanced error handling or retry logic for failed API requests.
- User authentication and authorization for API access must be managed externally. Currently None authorization is used.
- Limited to the auction data fields currently mapped; additional fields require code changes.
- Requires some additional translations to cs-CZ.

# User interfase
The app provides custom page within Microsoft Dynamics 365 Business Central where users can view, manage, and edit auction information. The page name is "Auction Info List" and it can be found from search panel.
Users can manually trigger the process to fetch auction data from the external API using provided actions on the relevant page.
Users also can create a job queue that will refresh (synchronize) the data from external service.
Permission set to all the objects inside the app is named "API Integration" and can be assigned to key users.
