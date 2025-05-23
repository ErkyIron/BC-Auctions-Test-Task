codeunit 50002 "PTE Install Helpers"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerCompany()
    begin
        InitializeApp();
    end;

    procedure InitializeApp()
    var
        APIIntegrationMgt: Codeunit "PTE API Integration Mgt.";
    begin
        APIIntegrationMgt.CreateDefaultJobQueueEntry();
    end;
}
