unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, ExtCtrls, IntervalArithmetic32and64;

type

  { TForm1 }

    TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    ListBox3: TListBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit6Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

  type
  vector  = array of Extended;
  vector1 = array of Extended;
  vector2 = array of Extended;
  vector3 = array of Extended;
  matrix  = array of array of Extended;

  interval_vector  = array of Interval;
  interval_vector1 = array of Interval;
  interval_vector2 = array of Interval;
  interval_vector3 = array of Interval;
  interval_matrix = array of array of Interval;


var
  Form1                 : TForm1;
  ilosc_wezlow, i, k    : Integer;
  x,f                   : vector;
  interval_x,interval_f : interval_vector;
  a                     : matrix;
  interval_a            : interval_matrix;

implementation

procedure periodsplinecoeffns (n         : Integer;
                               x,f       : vector;
                               var a     : matrix;
                               var st    : Integer);
{---------------------------------------------------------------------------}
{                                                                           }
{  The procedure periodsplinecoeffns calculates the coefficients of the     }
{  periodic cubic spline interpolant for a function given by its values at  }
{  nodes.                                                                   }
{  Data:                                                                    }
{    n  - number of interpolation nodes minus 1 (the nodes are numbered     }
{         from 0 to n),                                                     }
{    x  - an array containing the values of nodes,                          }
{    f  - an array containing the values of function (the value of f[0]     }
{         should be equal to the value of f[n]).                            }
{  Result:                                                                  }
{    a  - an array of spline coefficients (the element a[k,i] contains the  }
{         coefficient before x^k, where k=0,1,2,3, for the interval         }
{         <x[i], x[i+1]>; i=0,1,...,n-1).                                   }
{  Other parameters:                                                        }
{    st - a variable which within the procedure periodsplinecoeffns is      }
{         assigned the value of:                                            }
{           1, if n<1,                                                      }
{           2, if there exist x[i] and x[j] (i<>j; i,j=0,1,...,n) such      }
{              that x[i]=x[j],                                              }
{           3, if f[0]<>f[n],                                               }
{           0, otherwise.                                                   }
{         Note: If st<>0, then the elements of array a are not calculated.  }
{  Unlocal identifiers:                                                     }
{    vector  - a type identifier of extended array [q0..qn], where q0<=0    }
{              and qn>=n,                                                   }
{    vector1 - a type identifier of extended array [q1..qn], where q1<=1    }
{              and qn>=n,                                                   }
{    vector2 - a type identifier of extended array [q1..qn1], where q1<=1   }
{              and qn1>=n-1,                                                }
{    vector3 - a type identifier of extended array [q2..qn], where q2<=2    }
{              and qn>=n,                                                   }
{    matrix  - a type identifier of extended array [0..3, q0..qn1], where   }
{              q0<=0 and qn1>=n-1.                                          }
{                                                                           }
{---------------------------------------------------------------------------}
var i,k        : Integer;
    w,v,y,z,xi : Extended;
    u          : vector;
    b,c,d      : vector1;
    p          : vector2;
    q          : vector3;
begin

   SetLength(u,n);
   SetLength(b,n);
   SetLength(c,n);
   SetLength(d,n);
   SetLength(p,n);
   SetLength(q,n);

  if n<1
    then st:=1
    else if f[0]<>f[n]
           then st:=3
           else begin
                  st:=0;
                  i:=-1;
                  repeat
                    i:=i+1;
                    for k:=i+1 to n do
                      if x[i]=x[k]
                        then st:=2
                  until (i=n-1) or (st=2)
                end;
  if st=0
    then begin
           if n>1
             then begin
                    v:=x[1]-x[0];
                    z:=x[n]-x[n-1];
                    b[n]:=v/(z+v);
                    c[n]:=1-b[n];
                    y:=f[n];
                    d[n]:=6*((f[1]-y)/v-(y-f[n-1])/z)/(z+v);
                    for i:=1 to n-1 do
                      begin
                        z:=x[i];
                        y:=x[i+1]-z;
                        z:=z-x[i-1];
                        v:=f[i];
                        b[i]:=y/(y+z);
                        c[i]:=1-b[i];
                        d[i]:=6*((f[i+1]-v)/y-(v-f[i-1])/z)/(y+z)
                      end;
                    if n>2
                      then begin
                             u[1]:=2;
                             c[2]:=c[2]/2;
                             q[2]:=-b[n]/2;
                             for i:=2 to n-2 do
                               begin
                                 v:=2-b[i-1]*c[i];
                                 c[i+1]:=c[i+1]/v;
                                 q[i+1]:=-q[i]*b[i-1]/v;
                                 u[i]:=v
                               end;
                             v:=2-c[n-1]*b[n-2];
                             q[n]:=(c[n]-q[n-1]*b[n-2])/v;
                             u[n-1]:=v;
                             p[1]:=c[1];
                             for i:=2 to n-2 do
                               p[i]:=-c[i]*p[i-1];
                             p[n-1]:=b[n-1]-c[n-1]*p[n-2];
                             v:=2-c[1]*p[2];
                             for i:=2 to n-2 do
                               v:=v-p[i]*p[i+1];
                             u[n]:=v-p[n-1]*q[n];
                             for i:=2 to n-1 do
                               d[i]:=d[i]-c[i]*d[i-1];
                             v:=d[n];
                             for i:=2 to n do
                               v:=v-q[i]*d[i-1];
                             d[n]:=v;
                             u[n]:=d[n]/u[n];
                             u[n-1]:=(d[n-1]-p[n-1]*u[n])/u[n-1];
                             for i:=n-2 downto 1 do
                               u[i]:=(d[i]-b[i]*u[i+1]-p[i]*u[n])/u[i]
                           end
                      else begin
                             y:=d[1];
                             z:=d[2];
                             w:=4-c[2]*b[1];
                             u[1]:=(2*y-b[1]*z)/w;
                             u[2]:=(2*z-c[2]*y)/w;
                           end
                  end
             else u[1]:=0;
           u[0]:=u[n];
           for i:=0 to n-1 do
             begin
               w:=f[i];
               xi:=x[i];
               z:=x[i+1]-xi;
               y:=u[i];
               v:=(f[i+1]-w)/z-(2*y+u[i+1])*z/6;
               z:=(u[i+1]-y)/(6*z);
               y:=y/2;
               a[0,i]:=((-z*xi+y)*xi-v)*xi+w;
               w:=3*z*xi;
               a[1,i]:=(w-2*y)*xi+v;
               a[2,i]:=y-w;
               a[3,i]:=z
             end
         end
end;

procedure iperiodsplinecoeffns (n         : Integer;
                               x,f       : Interval_vector;
                               var interval_a     : Interval_matrix;
                               var st    : Integer);
{---------------------------------------------------------------------------}
{                                                                           }
{  The procedure periodsplinecoeffns calculates the coefficients of the     }
{  periodic cubic spline interpolant for a function given by its values at  }
{  nodes.                                                                   }
{  Data:                                                                    }
{    n  - number of interpolation nodes minus 1 (the nodes are numbered     }
{         from 0 to n),                                                     }
{    x  - an array containing the values of nodes,                          }
{    f  - an array containing the values of function (the value of f[0]     }
{         should be equal to the value of f[n]).                            }
{  Result:                                                                  }
{    a  - an array of spline coefficients (the element a[k,i] contains the  }
{         coefficient before x^k, where k=0,1,2,3, for the interval         }
{         <x[i], x[i+1]>; i=0,1,...,n-1).                                   }
{  Other parameters:                                                        }
{    st - a variable which within the procedure periodsplinecoeffns is      }
{         assigned the value of:                                            }
{           1, if n<1,                                                      }
{           2, if there exist x[i] and x[j] (i<>j; i,j=0,1,...,n) such      }
{              that x[i]=x[j],                                              }
{           3, if f[0]<>f[n],                                               }
{           0, otherwise.                                                   }
{         Note: If st<>0, then the elements of array a are not calculated.  }
{  Unlocal identifiers:                                                     }
{    vector  - a type identifier of extended array [q0..qn], where q0<=0    }
{              and qn>=n,                                                   }
{    vector1 - a type identifier of extended array [q1..qn], where q1<=1    }
{              and qn>=n,                                                   }
{    vector2 - a type identifier of extended array [q1..qn1], where q1<=1   }
{              and qn1>=n-1,                                                }
{    vector3 - a type identifier of extended array [q2..qn], where q2<=2    }
{              and qn>=n,                                                   }
{    matrix  - a type identifier of extended array [0..3, q0..qn1], where   }
{              q0<=0 and qn1>=n-1.                                          }
{                                                                           }
{---------------------------------------------------------------------------}
var i,k        : Integer;
    w,v,y,z,xi : Interval;
    u          : Interval_vector;
    b,c,d      : Interval_vector1;
    p          : Interval_vector2;
    q          : Interval_vector3;
begin

   SetLength(u,n);
   SetLength(b,n);
   SetLength(c,n);
   SetLength(d,n);
   SetLength(p,n);
   SetLength(q,n);
   SetLength(interval_a,4,n);

  if n<1
    then st:=1
    else if ((interval_f[0].a<>interval_f[n].a) OR (interval_f[0].b<>interval_f[n].b))
           then st:=3
           else begin
                  st:=0;
                  i:=-1;
                  repeat
                    i:=i+1;
                    for k:=i+1 to n do
                      if ((interval_x[i].a=interval_x[k].a) AND (interval_x[i].b=interval_x[k].b))
                        then st:=2
                  until (i=n-1) or (st=2)
                end;
  if st=0
    then begin
           if n>1
             then begin
                    v:=isub(interval_x[1],interval_x[0]);
                    z:=isub(interval_x[n],interval_x[n-1]);
                    b[n]:=idiv(v,iadd(z,v));
                    c[n]:=isub(int_read('1'),b[n]);
                    y:=interval_f[n];
                    d[n]:=idiv(imul(int_read('6'),isub(idiv(isub(interval_f[1],y),v),idiv(isub(y,interval_f[n-1]),z))),iadd(z,v));
                    for i:=1 to n-1 do
                      begin
                        z:=interval_x[i];
                        y:=isub(interval_x[i+1],z);
                        z:=isub(z,interval_x[i-1]);
                        v:=interval_f[i];
                        b[i]:=idiv(y,iadd(y,z));
                        c[i]:=isub(int_read('1'),b[i]);
                        d[i]:=idiv(imul(int_read('6'),isub(idiv(isub(f[i+1],v),y),idiv(isub(v,f[i-1]),z))),iadd(y,z))
                      end;
                    if n>2
                      then begin
                             u[1]:=int_read('2');
                             c[2]:=idiv(c[2],int_read('2'));
                             q[2]:=isub(int_read('0'),idiv(b[n],int_read('2')));
                             for i:=2 to n-2 do
                               begin
                                 v:=isub(int_read('2'),imul(b[i-1],c[i]));
                                 c[i+1]:=idiv(c[i+1],v);
                                 q[i+1]:=isub(int_read('0'),idiv(imul(q[i],b[i-1]),v));
                                 u[i]:=v
                               end;
                             v:=isub(int_read('2'),imul(c[n-1],b[n-2]));
                             q[n]:=idiv(isub(c[n],imul(q[n-1],b[n-2])),v);
                             u[n-1]:=v;
                             p[1]:=c[1];
                             for i:=2 to n-2 do
                               p[i]:=isub(int_read('0'),imul(c[i],p[i-1]));
                             p[n-1]:=isub(b[n-1],imul(c[n-1],p[n-2]));
                             v:=isub(int_read('2'),imul(c[1],p[2]));
                             for i:=2 to n-2 do
                               v:=isub(v,imul(p[i],p[i+1]));
                             u[n]:=isub(v,imul(p[n-1],q[n]));
                             for i:=2 to n-1 do
                               d[i]:=isub(d[i],imul(c[i],d[i-1]));
                             v:=d[n];
                             for i:=2 to n do
                               v:=isub(v,imul(q[i],d[i-1]));
                             d[n]:=v;
                             u[n]:=idiv(d[n],u[n]);
                             u[n-1]:=idiv(isub(d[n-1],imul(p[n-1],u[n])),u[n-1]);
                             for i:=n-2 downto 1 do
                               u[i]:=idiv(isub(isub(d[i],imul(b[i],u[i+1])),imul(p[i],u[n])),u[i]);
                           end
                      else begin
                             y:=d[1];
                             z:=d[2];
                             w:=isub(int_read('4'),imul(c[2],b[1]));
                             u[1]:=idiv(isub(imul(int_read('2'),y),imul(b[1],z)),w);
                             u[2]:=idiv(isub(imul(int_read('2'),z),imul(c[2],y)),w);
                           end
                  end
             else u[1]:=int_read('0');
           u[0]:=u[n];
           for i:=0 to n-1 do
             begin
               w:=interval_f[i];
               xi:=interval_x[i];
               z:=isub(interval_x[i+1],xi);
               y:=u[i];
               v:=isub(idiv(isub(f[i+1],w),z),idiv(imul(iadd(imul(int_read('2'),y),u[i+1]),z),int_read('6')));
               z:=idiv(isub(u[i+1],y),imul(int_read('6'),z));
               y:=idiv(y,int_read('2'));
               interval_a[0,i]:=iadd(imul(isub(imul(iadd(imul(isub(int_read('0'),z),xi),y),xi),v),xi),w);
               w:=imul(imul(int_read('3'),z),xi);
               interval_a[1,i]:=iadd(imul(isub(w,imul(int_read('2'),y)),xi),v);
               interval_a[2,i]:=isub(y,w);
               interval_a[3,i]:=z
             end
         end
end;

function periodsplinevalue (n      : Integer;
                            x,f    : vector;
                            xx     : Extended;
                            var st : Integer) : Extended;
{---------------------------------------------------------------------------}
{                                                                           }
{  The function periodsplinevalue calculates the value of the periodic      }
{  cubic spline interpolant for a function given by its values at nodes.    }
{  Data:                                                                    }
{    n  - number of interpolation nodes minus 1 (the nodes are numbered     }
{         from 0 to n),                                                     }
{    x  - an array containing the values of nodes,                          }
{    f  - an array containing the values of function (the value of f[0]     }
{         should be equal to the value of f[n]),                            }
{    xx - the point at which the value of interpolating spline should       }
{         be calculated.                                                    }
{  Result:                                                                  }
{    periodsplinevalue(n,x,f,xx,st) - the value of periodic spline at xx.   }
{  Other parameters:                                                        }
{    st - a variable which within the function periodsplinevalue is         }
{         assigned the value of:                                            }
{           1, if n<1,                                                      }
{           2, if there exist x[i] and x[j] (i<>j; i,j=0,1,...,n) such      }
{              that x[i]=x[j],                                              }
{           3, if f[0]<>f[n],                                               }
{           4, if xx<x[0] or xx>x[n],                                       }
{           0, otherwise.                                                   }
{         Note: If st<>0, then periodicsplinevalue(n,x,f,xx,st) is not      }
{               calculated.                                                 }
{  Unlocal identifiers:                                                     }
{    vector  - a type identifier of extended array [q0..qn], where q0<=0    }
{              and qn>=n,                                                   }
{    vector1 - a type identifier of extended array [q1..qn], where q1<=1    }
{              and qn>=n,                                                   }
{    vector2 - a type identifier of extended array [q1..qn1], where q1<=1   }
{              and qn1>=n-1,                                                }
{    vector3 - a type identifier of extended array [q2..qn], where q2<=2    }
{              and qn>=n.                                                   }
{                                                                           }
{---------------------------------------------------------------------------}
var i,k   : Integer;
    v,y,z : Extended;
    found : Boolean;
    a     : array [0..3] of Extended;
    u     : vector;
    b,c,d : vector1;
    p     : vector2;
    q     : vector3;
begin
      SetLength(u,n);
      SetLength(b,n);
      SetLength(c,n);
      SetLength(d,n);
      SetLength(p,n);
      SetLength(q,n);

  if n<1
    then st:=1
    else if f[0]<>f[n]
           then st:=3
           else if (xx<x[0]) or (xx>x[n])
                  then st:=4
                  else begin
                         st:=0;
                         i:=-1;
                         repeat
                           i:=i+1;
                           for k:=i+1 to n do
                             if x[i]=x[k]
                               then st:=2
                         until (i=n-1) or (st=2)
                       end;
  if st=0
    then begin
           if n>1
             then begin
                    v:=x[1]-x[0];
                    z:=x[n]-x[n-1];
                    b[n]:=v/(z+v);
                    c[n]:=1-b[n];
                    y:=f[n];
                    d[n]:=6*((f[1]-y)/v-(y-f[n-1])/z)/(z+v);
                    for i:=1 to n-1 do
                      begin
                        z:=x[i];
                        y:=x[i+1]-z;
                        z:=z-x[i-1];
                        v:=f[i];
                        b[i]:=y/(y+z);
                        c[i]:=1-b[i];
                        d[i]:=6*((f[i+1]-v)/y-(v-f[i-1])/z)/(y+z)
                      end;
                    if n>2
                      then begin
                             u[1]:=2;
                             c[2]:=c[2]/2;
                             q[2]:=-b[n]/2;
                             for i:=2 to n-2 do
                               begin
                                 v:=2-b[i-1]*c[i];
                                 c[i+1]:=c[i+1]/v;
                                 q[i+1]:=-q[i]*b[i-1]/v;
                                 u[i]:=v
                               end;
                             v:=2-c[n-1]*b[n-2];
                             q[n]:=(c[n]-q[n-1]*b[n-2])/v;
                             u[n-1]:=v;
                             p[1]:=c[1];
                             for i:=2 to n-2 do
                               p[i]:=-c[i]*p[i-1];
                             p[n-1]:=b[n-1]-c[n-1]*p[n-2];
                             v:=2-c[1]*p[2];
                             for i:=2 to n-2 do
                               v:=v-p[i]*p[i+1];
                             u[n]:=v-p[n-1]*q[n];
                             for i:=2 to n-1 do
                               d[i]:=d[i]-c[i]*d[i-1];
                             v:=d[n];
                             for i:=2 to n do
                               v:=v-q[i]*d[i-1];
                             d[n]:=v;
                             u[n]:=d[n]/u[n];
                             u[n-1]:=(d[n-1]-p[n-1]*u[n])/u[n-1];
                             for i:=n-2 downto 1 do
                               u[i]:=(d[i]-b[i]*u[i+1]-p[i]*u[n])/u[i]
                           end
                      else begin
                             y:=d[1];
                             z:=d[2];
                             v:=4-c[2]*b[1];
                             u[1]:=(2*y-b[1]*z)/v;
                             u[2]:=(2*z-c[2]*y)/v;
                           end
                  end
             else u[1]:=0;
           u[0]:=u[n];
           found:=False;
           i:=-1;
           repeat
             i:=i+1;
             if (xx>=x[i]) and (xx<=x[i+1])
               then found:=True
           until found;
           y:=x[i+1]-x[i];
           z:=u[i+1];
           v:=u[i];
           a[0]:=f[i];
           a[1]:=(f[i+1]-f[i])/y-(2*v+z)*y/6;
           a[2]:=v/2;
           a[3]:=(z-v)/(6*y);
           y:=a[3];
           z:=xx-x[i];
           for i:=2 downto 0 do
             y:=y*z+a[i];
           periodsplinevalue:=y
         end
end;

function iperiodsplinevalue (n      : Integer;
                            interval_x,interval_f    : interval_vector;
                            xx     : Interval;
                            var st : Integer) : Interval;
{---------------------------------------------------------------------------}
{                                                                           }
{  The function periodsplinevalue calculates the value of the periodic      }
{  cubic spline interpolant for a function given by its values at nodes.    }
{  Data:                                                                    }
{    n  - number of interpolation nodes minus 1 (the nodes are numbered     }
{         from 0 to n),                                                     }
{    x  - an array containing the values of nodes,                          }
{    f  - an array containing the values of function (the value of f[0]     }
{         should be equal to the value of f[n]),                            }
{    xx - the point at which the value of interpolating spline should       }
{         be calculated.                                                    }
{  Result:                                                                  }
{    periodsplinevalue(n,x,f,xx,st) - the value of periodic spline at xx.   }
{  Other parameters:                                                        }
{    st - a variable which within the function periodsplinevalue is         }
{         assigned the value of:                                            }
{           1, if n<1,                                                      }
{           2, if there exist x[i] and x[j] (i<>j; i,j=0,1,...,n) such      }
{              that x[i]=x[j],                                              }
{           3, if f[0]<>f[n],                                               }
{           4, if xx<x[0] or xx>x[n],                                       }
{           0, otherwise.                                                   }
{         Note: If st<>0, then periodicsplinevalue(n,x,f,xx,st) is not      }
{               calculated.                                                 }
{  Unlocal identifiers:                                                     }
{    vector  - a type identifier of extended array [q0..qn], where q0<=0    }
{              and qn>=n,                                                   }
{    vector1 - a type identifier of extended array [q1..qn], where q1<=1    }
{              and qn>=n,                                                   }
{    vector2 - a type identifier of extended array [q1..qn1], where q1<=1   }
{              and qn1>=n-1,                                                }
{    vector3 - a type identifier of extended array [q2..qn], where q2<=2    }
{              and qn>=n.                                                   }
{                                                                           }
{---------------------------------------------------------------------------}
var i,k   : Integer;
    v,y,z : Interval;
    found : Boolean;
    a     : array [0..3] of Interval;
    u     : interval_vector;
    b,c,d : interval_vector1;
    p     : interval_vector2;
    q     : interval_vector3;
begin
      SetLength(u,n);
      SetLength(b,n);
      SetLength(c,n);
      SetLength(d,n);
      SetLength(p,n);
      SetLength(q,n);

  if n<1
    then st:=1
    else if ((interval_f[0].a<>interval_f[n].a) OR (interval_f[0].b<>interval_f[n].b))
           then st:=3
           else if (xx.b<interval_x[0].a) or (xx.a>interval_x[n].b)
                  then st:=4
                  else begin
                         st:=0;
                         i:=-1;
                         repeat
                           i:=i+1;
                           for k:=i+1 to n do
                             if ((interval_x[i].a=interval_x[k].a) and (interval_x[i].b=interval_x[k].b))
                               then st:=2
                         until (i=n-1) or (st=2)
                       end;
  if st=0
    then begin
           if n>1
             then begin
                    v:=isub(interval_x[1],interval_x[0]);
                    z:=isub(interval_x[n],interval_x[n-1]);
                    b[n]:=idiv(v,iadd(z,v));
                    c[n]:=isub(int_read('1'),b[n]);
                    y:=interval_f[n];
                    d[n]:=imul(int_read('6'),idiv(isub(idiv(isub(interval_f[1],y),v),idiv(isub(y,interval_f[n-1]),z)),iadd(z,v)));
                    for i:=1 to n-1 do
                      begin
                        z:=interval_x[i];
                        y:=isub(interval_x[i+1],z);
                        z:=isub(z,interval_x[i-1]);
                        v:=interval_f[i];
                        b[i]:=idiv(y,iadd(y,z));
                        c[i]:=isub(int_read('1'),b[i]);
                        d[i]:=imul(int_read('6'),idiv(isub(idiv(isub(interval_f[i+1],v),y),idiv(isub(v,interval_f[i-1]),z)),iadd(y,z)));
                      end;
                    if n>2
                      then begin
                             u[1]:=int_read('2');
                             c[2]:=idiv(c[2],int_read('2'));
                             q[2]:=isub(int_read('0'),idiv(b[n],int_read('2')));
                             for i:=2 to n-2 do
                               begin
                                 v:=isub(int_read('2'),imul(b[i-1],c[i]));
                                 c[i+1]:=idiv(c[i+1],v);
                                 q[i+1]:=isub(int_read('0'),idiv(imul(q[i],b[i-1]),v));
                                 u[i]:=v
                               end;
                             v:=isub(int_read('2'),imul(c[n-1],b[n-2]));
                             q[n]:=idiv(isub(c[n],imul(q[n-1],b[n-2])),v);
                             u[n-1]:=v;
                             p[1]:=c[1];
                             for i:=2 to n-2 do
                               p[i]:=isub(int_read('0'),imul(c[i],p[i-1]));
                             p[n-1]:=isub(b[n-1],imul(c[n-1],p[n-2]));
                             v:=isub(int_read('2'),imul(c[1],p[2]));
                             for i:=2 to n-2 do
                             v:=isub(v,imul(p[i],p[i+1]));
                             u[n]:=isub(v,imul(p[n-1],q[n]));
                             for i:=2 to n-1 do
                               d[i]:=isub(d[i],imul(c[i],d[i-1]));
                             v:=d[n];
                             for i:=2 to n do
                               v:=isub(v,imul(q[i],d[i-1]));
                             d[n]:=v;
                             u[n]:=idiv(d[n],u[n]);
                             u[n-1]:=idiv(isub(d[n-1],imul(p[n-1],u[n])),u[n-1]);
                             for i:=n-2 downto 1 do
                               u[i]:=idiv(isub(isub(d[i],imul(b[i],u[i+1])),imul(p[i],u[n])),u[i]);
                           end
                      else begin
                             y:=d[1];
                             z:=d[2];
                             v:=isub(int_read('4'),imul(c[2],b[1]));
                             u[1]:=idiv(isub(imul(int_read('2'),y),imul(b[1],z)),v);
                             u[2]:=idiv(isub(imul(int_read('2'),z),imul(c[2],y)),v);
                           end
                  end
             else u[1]:=int_read('0');
           u[0]:=u[n];
           found:=False;
           i:=-1;
           repeat
             i:=i+1;
             if (xx.a>=interval_x[i].b) and (xx.b<=interval_x[i+1].a)
               then found:=True
           until found;
           y:=isub(interval_x[i+1],interval_x[i]);
           z:=u[i+1];
           v:=u[i];
           a[0]:=interval_f[i];
           a[1]:=isub(idiv(isub(interval_f[i+1],interval_f[i]),y),idiv(imul(iadd(imul(int_read('2'),v),z),y),int_read('6')));
           a[2]:=idiv(v,int_read('2'));
           a[3]:=idiv(isub(z,v),imul(int_read('6'),y));
           y:=a[3];
           z:=isub(xx,interval_x[i]);
           for i:=2 downto 0 do
             y:=iadd(imul(y,z),a[i]);
           iperiodsplinevalue:=y;
         end
end;

{$R *.lfm}

{ TForm1 }

//Należy używać do czytania str (z ustawioną precyzją na 26) i do pisania val!
//Do czytania dla przedziałowej - int_read

procedure TForm1.Button1Click(Sender: TObject);
begin

  //pobieranie ilości węzłów
  ilosc_wezlow:=StrToInt(Edit1.Text);
  Edit2.Text := IntToStr(ilosc_wezlow);

  //ustawianie rozmiaru tablic na dane
  SetLength(x,ilosc_wezlow);
  SetLength(f,ilosc_wezlow);
  SetLength(interval_x,ilosc_wezlow);
  SetLength(interval_f,ilosc_wezlow);
  SetLength(a,4,ilosc_wezlow-1);
  SetLength(interval_a,4,ilosc_wezlow-1);

  //inicjalizowanie zerami macierzy wynikowej dla współczynników
  for k:=0 to 3 do
           begin
                       for i:=0 to ilosc_wezlow-2 do
                       begin
                       a[k][i]:=0;
                       end;
           end;

   for k:=0 to 3 do
           begin
                       for i:=0 to ilosc_wezlow-2 do
                       begin
                       interval_a[k][i]:=int_read('0');
                       end;
           end;


  Edit3.Visible:=true;
  i:=0;
  Label2.Caption:='WĘZEŁ nr:'+IntToStr(i);
  Label2.Caption:='WARTOŚĆ W WĘŹLE nr:'+IntToStr(i);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
    wynik                                            : Extended;
    st, code                                         : Integer;
    interval_wynik                                   : Interval;
    lewy, prawy, wartosc_zwykla, wspolczynnik_zwykly : String;
begin

  //arytmetyka zwykła
  val(Edit3.Text,x[i],code);  //węzeł
  val(Edit4.Text,f[i],code);  //wartość

  //arytmetyka przedziałowa
  interval_x[i]:=int_read(Edit3.Text); //węzeł
  interval_f[i]:=int_read(Edit4.Text); //wartość

  i:=i+1;
  Label2.Caption:='WĘZEŁ nr:'+IntToStr(i);
  Label2.Caption:='WARTOŚĆ W WĘŹLE nr:'+IntToStr(i);

  //jeżeli uzupełniono wszystkie węzły
  if(i=ilosc_wezlow) then
  begin
  Edit3.visible:=false;
  Edit4.visible:=false;
  Label4.visible:=true;
  ListBox1.visible:=true;
                         //wypisanie węzłów i wartości (informacyjnie)
                         for k:=0 to ilosc_wezlow-1 do
                       begin
                       ListBox1.Items.add('x['+FloatToStr(k)+']='+FloatToStr(x[k])+'-> f['+FloatToStr(k)+']='+FloatToStr(f[k]));
                       end;
    //obliczenie wartości dla arytmetyki zwykłej
    st:=0;
    wynik:=periodsplinevalue(ilosc_wezlow-1,x,f,5,st);
    //obliczenie wartości dla arytmetyki przedziałowej
    st:=0;
    interval_wynik:=iperiodsplinevalue(ilosc_wezlow-1,interval_x,interval_f,int_read('5'),st);
    //wypisanie wartości dla arytmetyki zwykłej
    str(wynik,wartosc_zwykla);
    Edit5.Text := wartosc_zwykla;
    //wypisanie wartości dla arytmetyki przedziałowej
    iends_to_strings(interval_wynik,lewy,prawy);
    Edit6.Text := lewy;
    Edit7.Text := prawy;


    //obliczanie współczynników dla arytmetyki zwykłej
    st:=0;
    periodsplinecoeffns(ilosc_wezlow-1,x,f,a,st);

   //wypisanie współczynników dla arytmetyki zwykłej
    for k:=0 to ilosc_wezlow-2 do
           begin
                       for i:=0 to 3 do
                       begin
                       str(a[i][k],wspolczynnik_zwykly);
                       ListBox2.Items.add(wspolczynnik_zwykly);
                       end;
                       ListBox2.Items.add(' ');
           end;

      //obliczanie współczynników dla arytmetyki przedziałowej
  st:=0;
  iperiodsplinecoeffns(ilosc_wezlow-1,interval_x,interval_f,interval_a,st);

  //wypisanie współczynników dla arytmetyki przedziałowej
    for k:=0 to ilosc_wezlow-2 do
           begin
                       for i:=0 to 3 do
                       begin
                       iends_to_strings(interval_a[i][k],lewy,prawy);
                       ListBox3.Items.add('['+lewy+';'+prawy+']');
                       end;
                       ListBox3.Items.add(' ');
           end;

  SetLength(x,0);
  SetLength(f,0);
  SetLength(interval_x,0);
  SetLength(interval_f,0);
  SetLength(a,0,0);
  SetLength(interval_a,0,0);

  end;


  end;


procedure TForm1.Edit6Change(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;



end.

