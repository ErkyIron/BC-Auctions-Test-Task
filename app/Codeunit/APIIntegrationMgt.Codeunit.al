codeunit 50000 "PTE API Integration Mgt."
{
    Permissions = tabledata "PTE Auction Info" = rim;

    var
        RequestFailedErr: Label 'Request failed with status code: %1', Comment = '%1 - error code';
        ResponseReadErr: Label 'Response is imposible to read';
        JobQueueEntryCreatedMsg: Label 'Job Queue Entry created';


    trigger OnRun()
    var
        ResponseText: Text;
    begin
        ResponseText := SendRequest('https://cevd.gov.cz/opendata/drazby/drazby_2025.json');
        ParseResponse(ResponseText);
    end;

    procedure CreateDefaulJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"PTE API Integration Mgt.");
        if not JobQueueEntry.FindFirst() then begin
            JobQueueEntry.InitRecurringJob(60);
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
            JobQueueEntry.Validate("Object ID to Run", Codeunit::"PTE API Integration Mgt.");
            JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
            JobQueueEntry.Insert(true);
        end;
        if GuiAllowed then
            Message(JobQueueEntryCreatedMsg);
    end;

    procedure SendRequest(RequestUrl: Text) ResponseText: Text;
    var
        TempBlob: Codeunit "Temp Blob";
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        HttpContent: HttpContent;
        IStream: InStream;
    begin
        RequestMessage.SetRequestUri(RequestUrl);
        RequestMessage.Method('GET');
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Authorization', 'None');

        TempBlob.CreateInStream(IStream);
        HttpContent.WriteFrom(IStream);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        RequestMessage.Content(HttpContent);

        if HttpClient.Send(RequestMessage, ResponseMessage) and ResponseMessage.IsSuccessStatusCode then
            ResponseMessage.Content.ReadAs(ResponseText)
        else
            Error(RequestFailedErr, ResponseMessage.HttpStatusCode);
    end;

    procedure ParseResponse(ResponseText: Text)
    var
        AuctionInfo: Record "PTE Auction Info";
        JObject: JsonObject;
        JObject2: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
        JToken2: JsonToken;
        AuctionNo: Code[20];
        ContactInfo: Text;
    begin
        if ResponseText <> '' then
            if not JArray.ReadFrom(ResponseText) then
                Error(ResponseReadErr);

        foreach JToken in JArray do begin
            ContactInfo := '';
            AuctionNo := '';

            JObject := JToken.AsObject();
            JObject.SelectToken('zakladniInformace', JToken);
            JObject2 := JToken.AsObject();

            AuctionNo := GetNodeValue(JObject2, 'cisloDrazby', MaxStrLen(AuctionInfo."Auction No."));

            if AuctionNo <> '' then begin

                if not AuctionInfo.Get(AuctionNo) then begin
                    AuctionInfo.Init();
                    AuctionInfo."Auction No." := AuctionNo;
                    AuctionInfo.Insert();
                end;

                AuctionInfo."Negotiation No." := GetNodeValue(JObject2, 'cisloJednaci', MaxStrLen(AuctionInfo."Negotiation No."));

                if JObject2.SelectToken('osobaKontaktni', JToken2) then begin
                    ContactInfo += GetNodeValue(JToken2.AsObject(), 'jmeno', 0);
                    ContactInfo += ' ' + GetNodeValue(JToken2.AsObject(), 'prijmeni', 0);
                end;

                AuctionInfo."Contact Info" := CopyStr(ContactInfo, 1, MaxStrLen(AuctionInfo."Contact Info"));

                if JObject2.SelectToken('konaniDrazby', JToken2) then
                    AuctionInfo."Auction Url" := GetNodeValue(JToken2.AsObject(), 'url', MaxStrLen(AuctionInfo."Auction Url"));

                if JObject.SelectToken('nepovinneInformace', JToken2) then
                    AuctionInfo."Internal Note" := GetNodeValue(JToken2.AsObject(), 'ostatniInformace', MaxStrLen(AuctionInfo."Internal Note"));

                AuctionInfo.Modify();
                Commit(); // Commit loaded changes to the database
            end;
        end;
    end;

    local procedure GetNodeValue(JObject: JsonObject; JSonNodeName: Text; MaxValueLength: Integer): Text
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if JObject.SelectToken(JSonNodeName, JToken) then begin
            case true of
                JToken.IsValue():
                    JValue := JToken.AsValue();
                JToken.IsObject():
                    JValue := JToken.AsObject().AsToken().AsValue();
                JToken.IsArray():
                    JValue := JToken.AsArray().AsToken().AsValue();
            end;

            if JValue.IsNull() then
                exit('');

            if MaxValueLength <> 0 then
                exit(CopyStr(JValue.AsText(), 1, MaxValueLength))
            else
                exit(JValue.AsText());
        end;
    end;
}
