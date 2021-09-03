page 50152 "TFB Correct Ext. Doc. No."
{
    PageType = StandardDialog;
    Caption = 'Update Invoice External Document No.';
    Editable = true;


    layout
    {
        area(Content)
        {
            group(Main)
            {
                ShowCaption = false;

                field(CustomerName; _Customer.Name)
                {
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                    ShowCaption = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name for which expected payment date is provided';
                }
                group(References)
                {
                    ShowCaption = false;
                    Visible = true;

                    field(DocumentNo; _PreviousValues)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Style = Subordinate;
                        StyleExpr = true;
                        ShowCaption = false;
                    }
                }


                group(UpdateFields)
                {
                    ShowCaption = false;
                    field(ExternalDocNo; _ExternalDocNo)
                    {
                        Editable = true;
                        MultiLine = false;
                        Caption = 'New External Document No.';
                        ApplicationArea = All;
                        ToolTip = 'Specifies what the new external document will be';

                    }

                }
            }
        }
    }

    actions
    {


    }


    procedure GetExternalDocNo(): Code[35]

    begin
        Exit(_ExternalDocNo);
    end;


    procedure SetupCustomerInfo(Customer: Record Customer; ExternalDocNo: Code[35])
    var
        PreviousNote: TextBuilder;
    begin

        _Customer := Customer;




        if not (ExternalDocNo = '') then
            PreviousNote.AppendLine(StrSubstNo('Previous external document no was %1', ExternalDocNo))
        else
            PreviousNote.AppendLine('No prior external document number');


        _PreviousValues := PreviousNote.ToText();


    end;

    var
        _Customer: Record Customer;
        _ExternalDocNo: Text[512];
        _PreviousValues: Text;
        _DocumentNo: Text;


}