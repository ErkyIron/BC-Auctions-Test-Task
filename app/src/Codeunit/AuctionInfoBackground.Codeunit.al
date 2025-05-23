codeunit 50001 "PTE Auction Info Background"
{
    trigger OnRun()
    var
        APIIntegrationMgt: Codeunit "PTE API Integration Mgt.";
        TaskResults: Dictionary of [Text, Text];
        ResponseText: Text;
    begin
        TaskResults := Page.GetBackgroundParameters();

        TaskResults.Add(('Started'), Format(CurrentDateTime()));

        ResponseText := APIIntegrationMgt.SendRequest('https://cevd.gov.cz/opendata/drazby/drazby_2025.json');

        TaskResults.Add(('ResponseText'), ResponseText);
        TaskResults.Add(('Finished'), Format(CurrentDateTime()));

        Page.SetBackgroundTaskResult(TaskResults);
    end;
}
