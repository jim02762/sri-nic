; -*- TECO -*- NB: Use no tabs in this file!  TECO will barf.
@teco
* 1,111100000001.ez*.%.0           !* Which files we want!
* j <.-z;                           !* For whole list!
*   5,(f  +17):\u0                !* Make length string!
*   :l i.0
*0,NONE
*                                !* Insert an entry!
*   l>
* j <:s ;0>                     !* Change spaces to zeros!
* etchives.tags.-1                 !* Set output file!
* :ew hp :ef                      !* Dump the tag table!
=
@logout
