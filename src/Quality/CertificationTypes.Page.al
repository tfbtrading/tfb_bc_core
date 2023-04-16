page 50105 "TFB Certification Types"
{
    PageType = List;
    Caption = 'Certification Types';
    UsageCategory = Tasks;
    ApplicationArea = All;
    SourceTable = "TFB Certification Type";
    Editable = true;
    AdditionalSearchTerms = 'Quality Certification';
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;
    DataCaptionFields = Code, Name;
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies code for certification type';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies name of certification type';
                }
                field("GFSI Accredited"; Rec."GFSI Accredited")
                {
                    Tooltip = 'Specifies if certification type is GFSI accredited';
                }
                field(Class; Rec.Class)
                {
                    Tooltip = 'Specifies class of the certification';
                }

            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {

            action("Add logo")
            {
                Visible = true;

                Image = Import;
                Enabled = not LogoExists;
                Tooltip = 'Add a logo to the certification type';

                trigger OnAction()

                begin
                    AttachFile();
                end;

            }

            action("Remove logo")
            {
                Visible = true;

                Image = Delete;
                Enabled = LogoExists;
                ToolTip = 'Removes a logo from the certfiication type';

                trigger OnAction()

                begin
                    RemoveFile();
                end;

            }
        }

        area(Promoted)
        {
            actionref(AddLogo_Promoted; "Add logo")
            {

            }
            actionref(RemoveLogo_Promoted; "Remove logo")
            {

            }
        }
    }

    var
        LogoExists: Boolean;




    local procedure CheckIfLogoExists(): Boolean

    begin

        if Rec.Logo.HasValue() then
            exit(true)
        else
            exit(false);

    end;



    local procedure AttachFile()

    var
        FileManagement: CodeUnit "File Management";
        TempBlob: CodeUnit "Temp Blob";
        FileDialogTxt: Label 'Select Image File to Upload';
        FileName: Text;
        InStream: InStream;

    begin

        FileManagement.BLOBImportWithFilter(TempBlob, FileDialogTxt, '', '', '');

        if TempBlob.HasValue() then begin
            Clear(Rec.Logo);
            TempBlob.CreateInStream(InStream);
            Rec.Logo.ImportStream(InStream, FileName);
            Rec.Modify(true);

        end;
    end;




    local procedure RemoveFile()

    begin

        CLEAR(Rec.Logo);
        Rec.Modify(true);
        CheckIfLogoExists();

    end;

    trigger OnAfterGetRecord()

    begin
        LogoExists := CheckIfLogoExists();
    end;
}