pageextension 50290 "TFB Lot No. Information Card" extends "Lot No. Information Card" //6505
{

    layout
    {
        addafter("Item No.")
        {
            field("TFB Item Description"; Rec."TFB Item Description")
            {
                Caption = 'Description';
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies item description for lot';
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
        addlast(Inventory)
        {
            field("TFB No. Of Lot Images"; Rec."TFB No. Of Lot Images")
            {
                ApplicationArea = All;
                Visible = true;
                ToolTip = 'Specifies a count of the lot images taken for item ledger entries matching this lot';
                DrillDown = true;
                DrillDownPageId = "TFB Lot Images";
            }
        }

        addafter("Certificate Number")
        {
            group(Certificates)
            {

                field("TFB CoA Attached"; IsCoAAvailable)
                {
                    ApplicationArea = All;
                    AssistEdit = false;
                    Editable = false;
                    Caption = 'CoA Attached';
                    ToolTip = 'Specifies if certificate of analysis is attached';

                    trigger OnAssistEdit()
                    var
                        IDT: Enum "TFB Item Doc Type";

                    begin
                        IDT := IDT::COA;
                        AttachFile(IDT);
                    end;




                }

                field("TFB OPC Attached"; IsOPCAvailable)
                {
                    ApplicationArea = All;
                    AssistEdit = false;
                    Editable = false;
                    Enabled = IsOrganic;
                    Caption = 'OPC Attached';
                    ToolTip = 'Specifies if organic product certificate is attached';

                    trigger OnAssistEdit()

                    var
                        IDT: Enum "TFB Item Doc Type";

                    begin
                        IDT := IDT::OPC;
                        AttachFile(IDT);
                    end;

                }
            }
        }
        addafter(Blocked)
        {
            group(HiddenControl1)
            {
                ShowCaption = false;
                Visible = Rec.Blocked;

                field("TFB Date Available"; Rec."TFB Date Available")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies date on which blocked inventory will become available';
                }

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

        addafter("&Item Tracing")
        {
            action("Attach CoA")
            {

                ApplicationArea = All;
                Visible = true;

                Image = Import;
                Enabled = (not IsCoAAvailable);
                ToolTip = 'Attach a certificate of analysis to the lot information';

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
                Image = SendAsPDF;
                enabled = IsCoAAvailable;
                ToolTip = 'Download a certificate of analysis from lot information';
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

                Enabled = IsCoAAvailable;
                ToolTip = 'Remove a certificate of analysis from the lot information';

                trigger OnAction()

                var
                    IDT: Enum "TFB Item Doc Type";

                begin
                    IDT := IDT::COA;
                    RemoveFile(IDT);
                end;

            }
        }
        addlast(processing)
        {
            group("Organic Certificate")
            {


                action("Attach OPC")
                {

                    ApplicationArea = All;
                    Visible = true;


                    Image = Import;
                    Enabled = not IsOPCAvailable and IsOrganic;
                    ToolTip = 'Attach a organic product certificate to the lot information';

                    trigger OnAction()
                    var
                        IDT: Enum "TFB Item Doc Type";

                    begin
                        IDT := IDT::OPC;
                        AttachFile(IDT);
                    end;

                }
                action("Download OPC")
                {
                    ApplicationArea = All;
                    Visible = true;


                    Image = SendAsPDF;

                    Enabled = IsOPCAvailable and IsOrganic;
                    ToolTip = 'Download a organic product certificate from lot information';
                    trigger OnAction()
                    var
                        IDT: Enum "TFB Item Doc Type";

                    begin
                        IDT := IDT::OPC;
                        DownloadFile(IDT);
                    end;
                }
                action("Remove OPC")
                {
                    ApplicationArea = All;
                    Visible = true;

                    Image = Delete;

                    Enabled = IsOPCAvailable;
                    ToolTip = 'Remove a organic product certificate from the lot information';

                    trigger OnAction()
                    var
                        IDT: Enum "TFB Item Doc Type";

                    begin
                        IDT := IDT::OPC;
                        RemoveFile(IDT);
                    end;

                }
            }


        }
        addfirst(Category_Process)
        {

            group(Category_COA)
            {
                ShowAs = SplitButton;
                Image = Document;

                actionref(AttachCOARef; "Attach CoA")
                {

                }
                actionref(DownloadCOARef; "Download CoA")
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
        IsOrganic, IsCoAAvailable, IsOPCAvailable : Boolean;


    trigger OnAfterGetRecord()

    var
        IARec: Record "Item Attribute Value Mapping";
        IDT: Enum "TFB Item Doc Type";

    begin

        //TODO Change to dynamic configurable element
        IARec.SetRange("Item Attribute Value ID", 25);
        IARec.SetRange("No.", Rec."Item No.");

        if not IARec.IsEmpty() then IsOrganic := true else IsOrganic := false;

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