codeunit 50101 "Integration Utility"
{
    procedure InsertLog(IntegrationType: Enum "Integration Type"; IntegrationFn: Enum "Integration Function"; RequestData: Text; URL: Text): Integer
    var
        EntryNo: Integer;
        RecLog: Record "Integration Log Register";
    begin
        Clear(RecLog);
        if RecLog.FindLast() then
            EntryNo := RecLog."Entry No." + 1
        else
            EntryNo := 1;
        RecLog.Init();
        RecLog."Entry No." := EntryNo;
        RecLog."Integration Type" := IntegrationType;
        RecLog."Integration Function" := IntegrationFn;
        RecLog.SetRequestData(RequestData);
        RecLog."Request Time" := CurrentDateTime;
        RecLog.URL := URL;
        RecLog.Status := RecLog.Status::Failed;
        RecLog.Insert();
        exit(EntryNo);
    end;

    procedure ModifyLog(EntryNo: Integer; Status: Option " ",Success,Failed; ErrorText: Text; Response: Text)
    var
        RecLog: Record "Integration Log Register";
    begin
        If RecLog.GET(EntryNo) then begin
            RecLog.SetResponseData(Response);
            RecLog.Status := Status;
            RecLog."Error Text" := ErrorText;
            RecLog."Response Time" := CurrentDateTime;
            RecLog.Duration := RecLog."Response Time" - RecLog."Request Time";
            RecLog.Modify();
        end;
    end;


    procedure CallWebService(URL: Text; BodyText: Text; IntegrationFunction: Enum "Integration Function"): Text
    var
        RecIntegrationLog: Record "Integration Log Register";
        Intgration: Codeunit "Invoke Service";
        TypeEnum: Enum "Integration Type";
        LogEntryNo: Integer;
        Status: Option " ",Success,Failed;
        IsSuccess: Boolean;
        Response: Text;
    begin
        Clear(LogEntryNo);
        LogEntryNo := InsertLog(TypeEnum::"BC To SFA", IntegrationFunction, BodyText, URL);
        ClearLastError();
        Commit();
        Intgration.SetWebseriveProperties(URL, BodyText);
        if Intgration.Run() then begin
            Intgration.GetResponse(IsSuccess, Response);
            if IsSuccess then begin
                ModifyLog(LogEntryNo, Status::Success, '', Response);
                exit(Response);
            end else begin
                ModifyLog(LogEntryNo, Status::Failed, CopyStr(Response, 1, 250), Response);
                exit(Response);
            end;
        end else begin
            ModifyLog(LogEntryNo, Status::Failed, CopyStr(GetLastErrorText, 1, 250), GetLastErrorText);
            exit(GetLastErrorText);
        end;
    end;
}