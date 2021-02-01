page 50129 "TFB Cust. Cont. Stats. FactBox"
{
    Caption = 'Customer Contact Statistics';
    PageType = CardPart;
    SourceTable = Contact;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Date of Last Interaction"; Rec."Date of Last Interaction")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Shows the date of last interaction';
                }
                field("Last Date Attempted"; Rec."Last Date Attempted")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the date contact was last attempted unsuccessfully';
                }
                field("No. of Interactions"; Rec."No. of Interactions")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Shows the total number of interactions with the customer';
                }
                field("No. of Opportunities"; Rec."No. of Opportunities")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the number of open opportunities involving the contact. The field is not editable.';
                }
                field("TFB No. Of Tasks"; Rec."TFB No. Of Tasks")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Shows the total number of tasks related to this contact';
                    Visible = true;
                }
                group(CompanyOnly)
                {
                    Visible = Rec.Type = Rec.Type::Company;
                    field("TFB No. Of Individuals"; Rec."TFB No. Of Individuals")
                    {
                        ApplicationArea = RelationshipMgmt;
                        ToolTip = 'Specifies the number of individuals who work for the company';

                    }
                }
            }
            group(Segmentation)
            {
                Caption = 'Segmentation';

                field("No. of Industry Groups"; Rec."No. of Industry Groups")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the number of industry groups to which the contact belongs. When the contact is a person, this field contains the number of industry groups for the contact''s company. This field is not editable.';
                }

                field("No. of Mailing Groups"; Rec."No. of Mailing Groups")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the number of mailing groups for this contact.';
                }
            }
        }
    }


}