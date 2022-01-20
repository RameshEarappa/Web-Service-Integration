page 50101 "Integration Log Card"
{

    Caption = 'Integration Log Card';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Integration Log Register";
    DataCaptionFields = "Integration Type", "Integration Function";
    InsertAllowed = false;
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Posting,Prepare,Order,Request Approval,History,Print/Send,Navigate';
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
                field("Integration Type"; Rec."Integration Type")
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
                field("Integration Function"; Rec."Integration Function")
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
                field("Error Text"; Rec."Error Text")
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
                field(URL; Rec.URL)
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
                field("Request Time"; Rec."Request Time")
                {
                    Caption = 'Requested At';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Response Time"; Rec."Response Time")
                {
                    Caption = 'Responded At';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Download Request Data")
            {
                ApplicationArea = All;
                Image = WorkCenterLoad;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    Instr: InStream;
                    Filename: Text;
                begin
                    if Rec."Request Data".HasValue then begin
                        Rec.CalcFields("Request Data");
                        Rec."Request Data".CreateInStream(Instr);
                        Filename := StrSubstNo('%1_%2.xml', Rec."Integration Function", Rec."Entry No.");
                        DownloadFromStream(Instr, 'Export', '', 'All Files (*.*)|*.*', Filename);
                    end else
                        Error('The field Request Data must have a value.');
                end;
            }
            action("Download Response Data")
            {
                ApplicationArea = All;
                Image = WorkCenterLoad;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    Instr: InStream;
                    Filename: Text;
                begin
                    if Rec."Response Data".HasValue then begin
                        Rec.CalcFields("Response Data");
                        Rec."Response Data".CreateInStream(Instr);
                        Filename := StrSubstNo('%1_%2.xml', Rec."Integration Function", Rec."Entry No.");
                        DownloadFromStream(Instr, 'Export', '', 'All Files (*.*)|*.*', Filename);
                    end else
                        Error('The field Response Data must have a value.');
                end;
            }
        }
    }
}
