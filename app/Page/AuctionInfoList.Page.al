page 50000 "PTE Auction Info List"
{
    ApplicationArea = All;
    Caption = 'Auction Info List';
    PageType = List;
    SourceTable = "PTE Auction Info";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Auction No."; Rec."Auction No.")
                {
                    ToolTip = 'Specifies the value of the Auction No. field.';
                }
                field("Negotiation No."; Rec."Negotiation No.")
                {
                    ToolTip = 'Specifies the value of the Negotiation No. field.';
                }
                field("Auction Url"; Rec."Auction Url")
                {
                    ToolTip = 'Specifies the value of the Auction Url field.';
                }
                field("Contact Info"; Rec."Contact Info")
                {
                    ToolTip = 'Specifies the value of the Contact Info field.';
                }
                field("Internal Note"; Rec."Internal Note")
                {
                    ToolTip = 'Specifies the value of the Internal Note field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LoadInfo)
            {
                ApplicationArea = All;
                Caption = 'Load Info from API';
                ToolTip = 'Action will load Info from extenal API.';
                Image = Import;
                RunObject = Codeunit "PTE API Integration Mgt.";
            }
            action(CreateDefaultUpdateJob)
            {
                ApplicationArea = All;
                Caption = 'Create Default Update Job';
                ToolTip = ' Action will create default update job queue entry.';
                Image = Default;

                trigger OnAction()
                var
                    APIIntegrationMgt: Codeunit "PTE API Integration Mgt.";
                begin
                    APIIntegrationMgt.CreateDefaulJobQueueEntry();
                end;
            }
            action(ShowDefaultUpdateJob)
            {
                ApplicationArea = All;
                Caption = 'Show Default Update Job';
                ToolTip = ' Action will show default update job queue entry.';
                Image = ViewJob;

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                begin
                    JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
                    JobQueueEntry.SetRange("Object ID to Run", Codeunit::"PTE API Integration Mgt.");
                    if JobQueueEntry.FindSet() then;
                    Page.RunModal(Page::"Job Queue Entries", JobQueueEntry);
                end;
            }
        }
        area(Promoted)
        {
            actionref(LoadInfo_Promoted; LoadInfo)
            {
            }
            actionref(CreateDefaultUpdateJob_Promoted; CreateDefaultUpdateJob)
            {
            }
            actionref(ShowDefaultUpdateJob_Promoted; ShowDefaultUpdateJob)
            {
            }
        }
    }

    var
        SentUpdateRequest: Boolean;
        WaitTaskId: Integer;
        starttime: Text;
        endtime: Text;
        ShowNotificationId: Guid;
        BackgroundUpdateMsg: Label 'Background update of the records is triggered.';
        BackgroundUpdateFinishedMsg: Label 'Background update of the records is finished. Start %1 and finish %2 time of the update.', Comment = '%1 - start time, %2 - finish time';

    trigger OnOpenPage()
    begin
        // If Record is empty, create a new empty one to handle the Notification message + Background task
        if Rec.IsEmpty() then begin
            Rec.Init();
            if Rec.Insert() then;
        end;
    end;

    trigger OnClosePage()
    begin
        RemoveTemporaryEmptyRecord();
    end;

    trigger OnAfterGetCurrRecord()
    var
        TaskParameters: Dictionary of [Text, Text];
    begin
        if not SentUpdateRequest then begin
            CurrPage.EnqueueBackgroundTask(WaitTaskId, Codeunit::"PTE Auction Info Background", TaskParameters, 100000, PageBackgroundTaskErrorLevel::Warning);
            SendNotification(StrSubstNo(BackgroundUpdateMsg));
        end;
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        APIIntegrationMgt: Codeunit "PTE API Integration Mgt.";
        Started: Text;
        Finished: Text;
        ResponseText: Text;
    begin
        if (TaskId = WaitTaskId) then begin
            Started := Results.Get('Started');
            Finished := Results.Get('Finished');

            if Results.ContainsKey('ResponseText') then
                ResponseText := Results.Get('ResponseText');

            if ResponseText <> '' then begin
                APIIntegrationMgt.ParseResponse(ResponseText);
                RemoveTemporaryEmptyRecord();
            end;

            starttime := Started;
            endtime := Finished;

            SendNotification(StrSubstNo(BackgroundUpdateFinishedMsg, Started, Finished));
            SentUpdateRequest := true;
        end;
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    begin
        if (ErrorText <> '') or (ErrorCode <> '') then begin
            SentUpdateRequest := false;
            SendNotification(ErrorCode + ' ' + ErrorText);
        end;
    end;

    local procedure SendNotification(NotificationMessage: Text)
    var
        ShowNotification: Notification;
    begin
        if not IsNullGuid(ShowNotificationId) then
            ShowNotification.Id := ShowNotificationId;

        ShowNotification.Message(NotificationMessage);
        ShowNotification.Send();

        if IsNullGuid(ShowNotificationId) then
            ShowNotificationId := ShowNotification.Id;
    end;

    local procedure RemoveTemporaryEmptyRecord()
    var
        AuctionInfo: Record "PTE Auction Info";
    begin
        // Remove the record created for Notification message + Background task
        if AuctionInfo.Get() then
            AuctionInfo.Delete();
    end;

}
