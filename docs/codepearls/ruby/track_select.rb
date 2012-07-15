q = %{
  #{dbconfig[:nsdec]}
  let $tracks := (
	for $track in track
	#{
	  if where_clauses.empty? then ''
	  else 'where ' + where_clauses.join(' and ') end
	}
	#{
	  if order_by_clauses.empty? then ''
	  else 'order by ' + order_by_clauses.join(', ') end
	}
	return $track
	)
	for $track at $count in subsequence($tracks, #{offset + 1}, #{count})
	return
	  <track>
		{$track/uid}
		{$track/title}
		{$track/description}
		{$track/trackLength}
		{$track/createdDate}
		<startpoint><lat>{data($track/waypoints/waypoint[1]/@latitude)}</lat><lng>{data($track/waypoints/waypoint[1]/@longitude)}</lng></startpoint>
		<endpoint><lat>{data($track/waypoints/waypoint[last()]/@latitude)}</lat><lng>{data($track/waypoints/waypoint[last()]/@longitude)}</lng></endpoint>
		{if ($count=1) then <count>{count($tracks)}</count> else ()}
	  </track>
	}
query(q)
