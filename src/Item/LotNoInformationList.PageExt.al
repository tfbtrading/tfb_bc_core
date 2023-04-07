pageextension 50295 "TFB Lot No. Information List" extends "Lot No. Information List"
{

    layout
    {
        addafter("Lot No.")
        {

            field("TFB Sample Picture Exists"; Rec."TFB Sample Picture Exists")
            {
                Caption = 'Image Attached';
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies if a sample image has been attached';
            }
            field("TFB CoA Attached"; IsCoAAvailable)
            {
                Caption = 'CoA Attached';
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies if CoA is attached';
            }
            field("TFB OPC Attached"; IsOPCAvailable)
            {
                Caption = 'OPC Attached';
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies if OPC is attached';
            }
        }

        addafter("Item No.")
        {
            field("TFB Item Description"; Rec."TFB Item Description")
            {
                Caption = 'Description';
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies item description';
            }
        }

        modify(Description)
        {
            Caption = 'Additional Details';
        }
        modify("Test Quality")
        {
            Visible = false;
        }
        modify("Certificate Number")
        {
            Visible = false;
        }
        modify(Blocked)
        {
            Visible = true;

        }
        modify(Inventory)
        {
            Visible = true;
        }
        addlast(Control1)
        {

            field("TFB No. Of Lot Images"; Rec."TFB No. Of Lot Images")
            {
                ApplicationArea = All;
                Editable = false;
                DrillDown = true;
                DrillDownPageId = "TFB Lot Images";
                ToolTip = 'Specifies the count of lot images that have been added for item ledger entries related to this lot number';
            }
            field("TFB Date Available"; Rec."TFB Date Available")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies date at which lot becomes available';
            }
        }
        addlast(factboxes)
        {
            part(SamplePicture; "TFB Sample Picture")
            {
                ApplicationArea = All;
                Caption = 'Sample Picture';
                SubPageLink = SystemId = field(SystemId);
            }
        }

    }

    actions
    {
        addlast(processing)
        {

            action("Attach CoA")
            {

                ApplicationArea = All;
                Visible = true;

                Image = Import;
                Enabled = not IsCoAAvailable;
                ToolTip = 'Attach a certificate of analysis';

                trigger OnAction()
                var
                    IDT: Enum "TFB Item Doc Type";

                begin
                    IDT := IDT::COA;
                    AttachFile(IDT);
                end;

            }
            action("Download CoA")
            {
                ApplicationArea = All;
                Visible = true;
                Enabled = IsCoAAvailable;

                Image = SendAsPDF;
                ToolTip = 'Download a certificate of attachment as a pdf file';
                trigger OnAction()
                var
                    IDT: Enum "TFB Item Doc Type";

                begin
                    IDT := IDT::COA;
                    DownloadFile(IDT);
                end;
            }
            action("Remove CoA")
            {
                ApplicationArea = All;
                Visible = true;

                Image = Delete;
                ToolTip = 'Remove a certificate of analysis';
                Enabled = IsCoAAvailable;


                trigger OnAction()
                var
                    IDT: Enum "TFB Item Doc Type";

                begin
                    IDT := IDT::OPC;
                    RemoveFile(IDT);
                end;

            }

        }
        addlast(Promoted)
        {
            group(Category_COA)
            {
                Caption = 'CoA';
                ShowAs = SplitButton;

                actionref(DownloadCOARef; "Download CoA")
                {

                }
                actionref(AttachCOARef; "Attach CoA")
                {

                }
                actionref(RemoveCOARef; "Remove CoA")
                {

                }

            }
        }

    }


    local procedure AttachFile(IDT: Enum "TFB Item Doc Type")

    var
        LotInfoMgmtCU: Codeunit "TFB Lot Info Mgmt";
        Ref: BigInteger;

    begin


        Ref := LotInfoMgmtCU.AttachFile(IDT, Rec);
        if Ref > 0 then
            CheckIfAttachExists(IDT);

    end;


    local procedure DownloadFile(IDT: Enum "TFB Item Doc Type")

    var
        LotInfoMgmtCU: Codeunit "TFB Lot Info Mgmt";

    begin

        LotInfoMgmtCU.DownloadFile(IDT, Rec);

    end;



    local procedure RemoveFile(IDT: Enum "TFB Item Doc Type")

    var
        LotInfoMgmtCU: Codeunit "TFB Lot Info Mgmt";

    begin

        if LotInfoMgmtCU.RemoveFile(IDT, Rec) then
            CheckIfAttachExists(IDT);

    end;

    var
        IsCoAAvailable, IsOPCAvailable : Boolean;


    trigger OnAfterGetRecord()

    var
        IDT: Enum "TFB Item Doc Type";

    begin
        IDT := IDT::COA;
        CheckIfAttachExists(IDT);
        IDT := IDT::OPC;
        CheckIfAttachExists(IDT);

    end;

    local procedure CheckIfAttachExists(IDT: Enum "TFB Item Doc Type")

    var
        PersBlobCU: CodeUnit "Persistent Blob";

    begin


        case IDT of
            IDT::COA:
                IsCoAAvailable := PersBlobCU.Exists(Rec."TFB CoA Attach.");

            IDT::OPC:
                IsOPCAvailable := PersBlobCU.Exists(Rec."TFB OPC Attach.");

        end;

    end;


}